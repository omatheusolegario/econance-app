import 'dart:convert';
import 'dart:io';
import 'package:econance/features/transactions/add_transaction.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InvoiceCapturePage extends StatefulWidget {
  const InvoiceCapturePage({super.key});

  @override
  State<InvoiceCapturePage> createState() => _InvoiceCapturePageState();
}

class _InvoiceCapturePageState extends State<InvoiceCapturePage> with SingleTickerProviderStateMixin {
  File? _image;
  bool _loading = false;
  final picker = ImagePicker();
  late GenerativeModel _model;
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;
  int _currentCameraIndex = 0;
  List<CameraDescription> _cameras = [];
  File? _frozenFrame;
  bool _isFrozen = false;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scanAnimation = CurvedAnimation(parent: _scanController, curve: Curves.easeInOut);
    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _frozenFrame = null;
        });
      }
    });
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final allCameras = await availableCameras();
      CameraDescription? backCamera;
      CameraDescription? frontCamera;
      for (final cam in allCameras) {
        if (cam.lensDirection == CameraLensDirection.back && backCamera == null) {
          backCamera = cam;
        } else if (cam.lensDirection == CameraLensDirection.front && frontCamera == null) {
          frontCamera = cam;
        }
      }
      _cameras = [
        if (backCamera != null) backCamera,
        if (frontCamera != null) frontCamera,
      ];
      if (_cameras.isNotEmpty) {
        _currentCameraIndex = 0;
        _controller = CameraController(_cameras[_currentCameraIndex], ResolutionPreset.high);
        _initializeControllerFuture = _controller!.initialize();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhuma câmera compatível encontrada.")));
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permissão da câmera é necessária.")));
    }
  }

  Future<void> _flipCamera() async {
    if (_isFrozen) return;
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    _controller = CameraController(_cameras[_currentCameraIndex], ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    if (_isFrozen) return;
    if (_controller != null && _controller!.value.isInitialized) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _initializeControllerFuture;
      setState(() {
        _isFrozen = true;
        _loading = false;
      });
      final image = await _controller!.takePicture();
      _frozenFrame = File(image.path);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _loading = true;
      });
      if (_frozenFrame != null) {
        await _performOCR(_frozenFrame!);
      }
      setState(() {
        _isFrozen = false;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _isFrozen = false;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isFrozen) return;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _frozenFrame = _image;
        _isFrozen = true;
        _loading = true;
      });
      await Future.delayed(const Duration(milliseconds: 100));
      await _performOCR(_frozenFrame!);
      setState(() {
        _isFrozen = false;
        _loading = false;
      });
    }
  }

  Future<Map<String, String>> _fetchExpenseCategories() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    final categoriesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .where('type', isEqualTo: 'expense')
        .get();
    return {for (final doc in categoriesSnapshot.docs) doc.id: doc['name'] as String};
  }

  Future<String?> _createNewCategory(String suggestedName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final newDocRef = await FirebaseFirestore.instance.collection('users').doc(uid).collection('categories').add({
      'type': 'expense',
      'name': suggestedName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return newDocRef.id;
  }

  Future<void> _performOCR(File file) async {
    setState(() {
      _loading = true;
    });
    try {
      final bytes = await file.readAsBytes();
      final categories = await _fetchExpenseCategories();
      final categoriesJson = jsonEncode(categories);
      final content = [
        Content.multi([
          TextPart(
            'Extract the following from this Brazilian invoice image as JSON:'
                '{"date": "DD/MM/YYYY", "total": "XX.XX", "cnpj": "XX.XXX.XXX/XXXX-XX", "items":[{"name": "full description", "value": "XX.XX"}]}'
                'For number use "." to represent decimal values'
                'Be accurate with formats. If missing, use "".'
                'Focus on the main purchase details; ignore headers/footers if irrelevant.'
                '\nExisting expense categories (id:name):$categoriesJson.'
                'Based on the items or store, match to the closest category if reasonable (e.g., food items to "Groceries").'
                'Include "categoryId": "matching_id" in JSON if match found'
                'If no good match, include "suggestedCategoryName":"logical new name" (e.g., "Supermarket" for general purchases).'
                'Be careful to not send wrongly, it could crash the Flutter App',
          ),
          DataPart('image/png', bytes),
        ]),
      ];
      final response = await _model.generateContent(content);
      final jsonText = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '{}';
      Map<String, dynamic> parsedResult;
      try {
        final decoded = jsonDecode(jsonText);
        parsedResult = (decoded is Map<String, dynamic>) ? decoded : {};
      } catch (_) {
        parsedResult = {};
      }
      String? categoryId = parsedResult['categoryId'] as String?;
      if (categoryId == null && parsedResult['suggestedCategoryName'] != null) {
        categoryId = await _createNewCategory(parsedResult['suggestedCategoryName'] as String);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Created new category: ${parsedResult['suggestedCategoryName']}")));
      }
      if (parsedResult['total'] != null && parsedResult['total'].isNotEmpty) {
        if (context.mounted) {
          _scanController.stop();
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            builder: (context) => AddTransactionPage(
              type: 'expense',
              isInvoice: true,
              initialDate: parsedResult['date'],
              initialValue: parsedResult['total'],
              initialItems: (parsedResult['items'] as List<dynamic>?)
                  ?.map((item) => {'name': item['name'] ?? '', 'value': item['value'] ?? ''})
                  .toList() ??
                  [],
              initialCategoryId: categoryId,
              initialNote: parsedResult['cnpj'] != null ? 'Invoice from CNPJ: ${parsedResult['cnpj']}' : '',
            ),
          ).whenComplete(() {
            setState(() {
              _frozenFrame = null;
              _scanController.repeat(reverse: true);
            });
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient data extracted to prefill transaction')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI extraction error: $e")));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null && !_isFrozen && _frozenFrame == null)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller!);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            else if (_frozenFrame != null)
              Image.file(_frozenFrame!, fit: BoxFit.cover)
            else
              Container(color: Colors.black),
            if (_frozenFrame != null && _scanController.isAnimating)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  final t = _scanAnimation.value;
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.15 +
                        (MediaQuery.of(context).size.height * 0.6) * t,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(height: 3, color: theme.primaryColor),
                    ),
                  );
                },
              ),
            //if (_loading) const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 10,
              left: 5,
              right: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: _isFrozen ? null : () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
                  Column(
                    children: [
                      Text("Scan the Invoice", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text("and register your expense", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                  IconButton(onPressed: _isFrozen ? null : _toggleFlash, icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off)),
                ],
              ),
            ),
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.photo_library), color: Colors.green, onPressed: _isFrozen ? null : _pickFromGallery),
                  FloatingActionButton(onPressed: _isFrozen ? null : _captureImage, backgroundColor: Colors.green, child: const Icon(Icons.camera, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.flip_camera_android, color: Colors.green), onPressed: _isFrozen ? null : _flipCamera),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'Scan the invoice provided by the cashier, click on the flash on the top right corner to use the flash',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
