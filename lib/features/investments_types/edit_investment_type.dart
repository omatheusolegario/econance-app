import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditInvestmentTypePage extends StatefulWidget {
  final String typeId;
  final String initialName;
  final String uid;
  const EditInvestmentTypePage({
    super.key,
    required this.typeId,
    required this.initialName,
    required this.uid
  });

  @override
  State<EditInvestmentTypePage> createState() => _EditInvestmentTypePageState();
}

class _EditInvestmentTypePageState extends State<EditInvestmentTypePage> {
  late final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  Future<void> _updateType() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('investments_types')
        .doc(widget.typeId)
        .update({
      'name': _nameController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Type updated")),
    );
    Navigator.pop(context);
  }

  Future<void> _deleteType() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid) // use widget.uid aqui também
        .collection('investments_types')
        .doc(widget.typeId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Type deleted")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10.0,
          right: 20.0,
          left: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text("Name", style: theme.textTheme.bodySmall),
            const SizedBox(height: 7),
            TextField(
              controller: _nameController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(hintText: "e.g. Stocks"),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateType,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _deleteType,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
