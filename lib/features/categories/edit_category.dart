import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategoryPage extends StatefulWidget {
  final String categoryId;
  final String uid;
  final String initialName;
  final String initialType;

  const EditCategoryPage({
    super.key,
    required this.uid,
    required this.categoryId,
    required this.initialName,
    required this.initialType,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  late final _nameController = TextEditingController();
  late String? _type;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _nameController.text = widget.initialName;
  }

  Future<void> _updateCategory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('categories')
        .doc(widget.categoryId)
        .update({
          'name': _nameController.text.trim(),
          'type': _type,
          'createdAt': FieldValue.serverTimestamp(),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Category updated")));
    Navigator.pop(context);
  }

  Future<void> _deleteCategory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('categories')
        .doc(widget.categoryId)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Category deleted")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
            padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2)
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
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
                  initialValue: _type,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(hintText: "Select a category type"),
                  items: [
                    DropdownMenuItem(value: "expense", child: Text("Expense")),
                    DropdownMenuItem(value: "revenue", child: Text("Revenue")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateCategory,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: _deleteCategory,
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
