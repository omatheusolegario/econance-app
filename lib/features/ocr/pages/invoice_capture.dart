import 'dart:convert';
import 'dart:io';
import 'package:econance/features/transactions/add_transaction.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class InvoiceCapturePage extends StatefulWidget {
  const InvoiceCapturePage({super.key});

  @override
  State<InvoiceCapturePage> createState() => _InvoiceCapturePageState();
}

class _InvoiceCapturePageState extends State<InvoiceCapturePage> {
  File? _image;
  Map<String, dynamic>? _ocrResult;
  bool _loading = false;
  final picker = ImagePicker();
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: "AIzaSyB94OyBMfC1GxL6pBZokQohPH8Z0KPSz0c",
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
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
            'Be accurate with formats. If missing, use "".'
            'Focus on the main purchase details; ignore headers/footers if irrelevant.'
            '\nExisting expense categories (id:name):$categoriesJson.'
            'Based on the items or store, match to the closest category if reasonable (e.g., food items to "Groceries").'
            'Include "categoryId": "matching_id" in JSON if match found'
            'If no good match, include "suggestedCategoryName":"logical new name" (e.g., "Supermarket" for general purchases).',
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
      final parsedResult = jsonDecode(jsonText) as Map<String, dynamic>;

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

      setState(() {
        _ocrResult = {
          'date': parsedResult['date'] ?? '',
          'total': parsedResult['total'] ?? '',
          'cnpj': parsedResult['cnpj'] ?? '',
          'items':
              (parsedResult['items'] as List<dynamic>?)
                  ?.map(
                    (item) => {
                      'name': item['name'] ?? '',
                      'value': item['value'] ?? '',
                    },
                  )
                  .toList() ??
              [],
          'raw': response.text ?? '',
        };
      });

      if (parsedResult['total'] != null && parsedResult['total'].isNotEmpty) {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
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
                      .toList() ?? [],
              initialCategoryId: categoryId,
              initialNote: parsedResult['cnpj'] != null
                  ? 'Invoice from CNPJ: ${parsedResult['cnpj']}'
                  : '',
            ),
          );
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Here you'll be able to,",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
              Text(
                "Scan an Invoice",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (_image != null) ...[
                Image.file(_image!, height: 250),
                const SizedBox(height: 16),
              ],
              if (_loading) const CircularProgressIndicator(),
              if (_ocrResult != null) ...[
                Text(
                  'Date: ${_ocrResult!['date']}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Total: ${_ocrResult!['total']}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'CNPJ: ${_ocrResult!['cnpj']}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text("Items:", style: theme.textTheme.bodyMedium),
                ...((_ocrResult!['items'] as List<dynamic>?) ?? [])
                    .map((item) => Text("- ${item['name']}: ${item['value']}"))
                    .toList(),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take Photo"),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Pick from Gallery"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
