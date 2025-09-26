import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRevenuePage extends StatefulWidget {
  const AddRevenuePage({super.key});

  @override
  State<AddRevenuePage> createState() => _AddRevenuePageState();
}

class _AddRevenuePageState extends State<AddRevenuePage> {
  final _value = TextEditingController();
  final _source = TextEditingController();
  final _categoryId = TextEditingController();
  final _note = TextEditingController();

  Future<void> addRevenue() async{
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).collection('categories').add({
      'type': 'revenue',
      'value': _value.text.trim(),
      'source': _source.text.trim(),
      'categoryId': _categoryId.text.trim(),
      'note': _note.text.trim(),
      'date': DateTime.now(),
      'createdAt': FieldValue.serverTimestamp()
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Revenue added")));
    _value.clear();
    _source.clear();
    _categoryId.clear();
    _note.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical:0.0 ,horizontal:30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add new Revenue",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 70),
            Text(
              "Value",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 7),
            TextField(
              style:  theme.textTheme.bodyMedium,
              controller: _value,
              decoration: InputDecoration(hintText: "Ex: 409"),
            ),
            const SizedBox(height: 15),
            Text(
              "Source",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 7),
            TextField(
              style:  theme.textTheme.bodyMedium,
              controller: _source,
              decoration: InputDecoration(hintText: "Ex: Salary"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addRevenue,
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
