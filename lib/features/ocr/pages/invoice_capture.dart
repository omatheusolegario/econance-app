import 'dart:convert';
import 'dart:io';
import 'package:econance/features/transactions/add_transaction.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:econance/theme/responsive_colors.dart';

class InvoiceCapturePage extends StatefulWidget {
  const InvoiceCapturePage({super.key});

  @override
  State<InvoiceCapturePage> createState() => _InvoiceCapturePageState();
}

class _InvoiceCapturePageState extends State<InvoiceCapturePage>
    with SingleTickerProviderStateMixin {
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

    _scanAnimation =
        CurvedAnimation(parent: _scanController, curve: Curves.easeInOut);

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final allCameras = await availableCameras();
      CameraDescription? backCamera;
      CameraDescription? frontCamera;

      for (final cam in allCameras) {
        if (cam.lensDirection == CameraLensDirection.back &&
            backCamera == null) {
          backCamera = cam;
        } else if (cam.lensDirection == CameraLensDirection.front &&
            frontCamera == null) {
          frontCamera = cam;
        }
      }

      _cameras = [
        if (backCamera != null) backCamera,
        if (frontCamera != null) frontCamera,
      ];

      if (_cameras.isNotEmpty) {
        _currentCameraIndex = 0;
        _controller = CameraController(
          _cameras[_currentCameraIndex],
          ResolutionPreset.high,
        );
        _initializeControllerFuture = _controller!.initialize();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cameraNotFound)),
        );
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cameraPermissionRequired)),
      );
    }
  }

  Future<void> _flipCamera() async {
    if (_isFrozen || _cameras.length < 2) return;
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
    if (_isFrozen || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
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

      setState(() => _loading = true);

      if (_frozenFrame != null) {
        await _performOCR(_frozenFrame!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.captureImageError}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFrozen = false;
          _loading = false;
        });
      }
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
    }
  }

  Future<Map<String, String>> _fetchExpenseCategories() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("Usuário não autenticado");
    final categoriesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .where('type', isEqualTo: 'expense')
        .get();
    return {
      for (final doc in categoriesSnapshot.docs) doc.id: doc['name'] as String
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
    if (!mounted) return;
    setState(() {
      _loading = true;
      _isFrozen = true;
    });

    try {
      final bytes = await file.readAsBytes();
      final categories = await _fetchExpenseCategories();
      final categoriesJson = jsonEncode(categories);

      final content = [
        Content.multi([
          TextPart(
            'Extract the following from this Brazilian invoice image as JSON:'
                '{"date": "DD/MM/YYYY", "total": "XX.XX", "cnpj": "XX.XXX.XXX/XXXX-XX", '
                '"items":[{"name": "full description", "value": "XX.XX"}]} '
                'Use "." for decimals. Be accurate with formats. If missing, use "".'
                'Focus on main purchase details; ignore irrelevant headers/footers.'
                '\nExisting expense categories (id:name):$categoriesJson.'
                'Match items/store to closest category if reasonable.'
                'Include "categoryId" if matched, else "suggestedCategoryName".',
          ),
          DataPart('image/png', bytes),
        ]),
      ];

      final response = await _model.generateContent(content);
      final jsonText = response.text
          ?.replaceAll('```json', '')
          .replaceAll('```', '')
          .trim() ??
          '{}';

      Map<String, dynamic> parsedResult;
      try {
        final decoded = jsonDecode(jsonText);
        parsedResult = (decoded is Map<String, dynamic>) ? decoded : {};
      } catch (_) {
        parsedResult = {};
      }

      String? categoryId = parsedResult['categoryId'] as String?;
          if (categoryId == null && parsedResult['suggestedCategoryName'] != null) {
        categoryId = await _createNewCategory(
            parsedResult['suggestedCategoryName'] as String);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.newCategoryCreatedPrefix}: ${parsedResult['suggestedCategoryName']}'),
            ),
          );
        }
      }

      final total = parsedResult['total'];
      if (total is String && total.isNotEmpty && mounted) {
        _scanController.stop();
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          builder: (context) => AddTransactionPage(
            type: 'expense',
            isInvoice: true,
            initialDate: parsedResult['date'] ?? '',
            initialValue: total,
            initialItems: (parsedResult['items'] as List<dynamic>?)
                ?.map((item) => {
              'name': item['name'] ?? '',
              'value': item['value'] ?? '',
            })
                .toList() ??
                [],
            initialCategoryId: categoryId,
            initialNote: parsedResult['cnpj'] != null
                ? 'Invoice from CNPJ: ${parsedResult['cnpj']}'
                : '',
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.couldNotExtractSufficientData)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.ocrExtractionError}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _frozenFrame = null;
          _isFrozen = false;
          _loading = false;
          _scanController.repeat(reverse: true);
        });
      }
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
              Container(color: theme.scaffoldBackgroundColor),
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
            Positioned(
              top: 10,
              left: 5,
              right: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed:
                      _isFrozen ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios)),
                  Column(
                    children: [
            Text(AppLocalizations.of(context)!.scanInvoiceTitle,
              style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
            Text(AppLocalizations.of(context)!.scanInvoiceSubtitle,
              style: theme.textTheme.bodySmall
                ?.copyWith(color: ResponsiveColors.hint(theme))),
                    ],
                  ),
                  IconButton(
                    onPressed: _isFrozen ? null : _toggleFlash,
                    icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: ResponsiveColors.onBackground(theme)),
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
                    icon: Icon(Icons.photo_library),
                    color: ResponsiveColors.success(theme),
                    onPressed: _isFrozen ? null : _pickFromGallery,
                  ),
                  FloatingActionButton(
                    onPressed: _isFrozen ? null : _captureImage,
                    backgroundColor: ResponsiveColors.success(theme),
                    child:
                    Icon(Icons.camera_alt, color: ResponsiveColors.onPrimary(theme)),
                  ),
                  IconButton(
                    icon: Icon(Icons.flip_camera_android,
                        color: ResponsiveColors.success(theme)),
                    onPressed: _isFrozen ? null : _flipCamera,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ResponsiveColors.success(theme),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.invoiceInstructions,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: ResponsiveColors.onPrimary(theme)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (_loading)
              Positioned.fill(
                child: Container(
                  color: ResponsiveColors.onBackground(theme).withOpacity(0.45),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
