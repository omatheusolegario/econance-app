import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:econance/features/transactions/add_transaction.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class InvoiceCapturePage extends StatefulWidget {
  const InvoiceCapturePage({super.key});

  @override
  State<InvoiceCapturePage> createState() => _InvoiceCapturePageState();
}

class _InvoiceCapturePageState extends State<InvoiceCapturePage> {
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

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: "AIzaSyB94OyBMfC1GxL6pBZokQohPH8Z0KPSz0c",
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.isEmpty) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    _controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    if (_controller != null && _controller!.value.isInitialized) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _image = File(image.path);
      });
      await _performOCR(_image!);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _performOCR(_image!);
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

    return {
      for (final doc in categoriesSnapshot.docs) doc.id: doc['name'] as String,
    };
  }

  Future<String?> _createNewCategory(String suggestedName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final newDocRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .add({
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
            '{"date": "DD/MM/YYYY", "total": "XX.XX" (number only), "cnpj": "XX.XXX.XXX/XXXX-XX", "items":[{"name": "full description", "value": "XX.XX"}]'
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
      final jsonText =
          response.text
              ?.replaceAll('```json', '')
              .replaceAll('```', '')
              .trim() ??
          '{}';
      Map<String, dynamic> parsedResult;
     try{
       final decoded = jsonDecode(jsonText);
       parsedResult = (decoded is Map<String, dynamic>)? decoded : {};
     } catch(_){
       parsedResult = {};
     }


      String? categoryId = parsedResult['categoryId'] as String?;
      if (categoryId == null && parsedResult['suggestedCategoryName'] != null) {
        categoryId = await _createNewCategory(
          parsedResult['suggestedCategoryName'] as String,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Created new category: ${parsedResult['suggestedCategoryName']}",
            ),
          ),
        );
      }

      if (parsedResult['total'] != null && parsedResult['total'].isNotEmpty) {
        if (context.mounted) {

          if (_controller != null && _controller!.value.isInitialized) {
            try {
              await _controller!.setFlashMode(FlashMode.off);
              final lastFrame = await _controller!.takePicture();
              _frozenFrame = File(lastFrame.path);
              setState(() {
              });
            } catch (_) {
              _frozenFrame = null;
            }
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => AddTransactionPage(
              type: 'expense',
              isInvoice: true,
              initialDate: parsedResult['date'],
              initialValue: parsedResult['total'],
              initialItems:
                  (parsedResult['items'] as List<dynamic>?)
                      ?.map(
                        (item) => {
                          'name': item['name'] ?? '',
                          'value': item['value'] ?? '',
                        },
                      )
                      .toList() ??
                  [],
              initialCategoryId: categoryId,
              initialNote: parsedResult['cnpj'] != null
                  ? 'Invoice from CNPJ: ${parsedResult['cnpj']}'
                  : '',
            ),
          ).whenComplete((){
            setState(() {
              _frozenFrame = null;
            });
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient data extracted to prefill transaction'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("AI extraction error: $e")));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            if (_controller != null && _frozenFrame == null)
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
              Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_frozenFrame!, fit: BoxFit.cover),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(color: Colors.black),


            if (_loading) const Center(child: CircularProgressIndicator()),

            Positioned(
              top: 10,
              left: 5,
              right: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios),
                  ),

                  Column(
                    children: [
                      Text(
                        "Scan the Invoice",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "and register your expense",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                  ),
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
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    color: Colors.green,
                    onPressed: _pickFromGallery,
                  ),
                  FloatingActionButton(
                    onPressed: _captureImage,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.camera, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.flip_camera_android,
                      color: Colors.green,
                    ),
                    onPressed: _flipCamera,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
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
