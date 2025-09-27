import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/app_localizations.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {

  final _nameController = TextEditingController();
  String? type;

  Future<void> addCategory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .add({
          'name': _nameController.text.trim(),
          'type': type,
          'createdAt': FieldValue.serverTimestamp(),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Category added")));
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add new Category",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Text("Name", style: theme.textTheme.bodySmall),
            const SizedBox(height: 7),
            TextField(
              style: theme.textTheme.bodyMedium,
              controller: _nameController,
              decoration: InputDecoration(hintText: "Ex: Food"),
            ),
            const SizedBox(height: 15),
            Text("Type", style: theme.textTheme.bodySmall),
            const SizedBox(height: 7),
            DropdownButtonFormField(
              initialValue: type,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(hintText: "Select a category type"),
              items: [
                DropdownMenuItem(
                  value: "expense",
                  child: Text("Expense"),
                ),
                DropdownMenuItem(
                  value: "revenue",
                  child: Text("Revenue"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  type = value;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addCategory,
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
