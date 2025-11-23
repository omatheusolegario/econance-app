import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/app_localizations.dart';

class CategoryPickerPage extends StatefulWidget {
  final String type;
  const CategoryPickerPage({super.key, required this.type});

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  String _search = "";
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchCategoriesHint,
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _search = value.toLowerCase();
            });
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('categories')
            .where('type', isEqualTo: widget.type)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = snapshot.data!.docs.where((doc) {
            final name = (doc['name'] as String).toLowerCase();
            return _search.isEmpty || name.contains(_search);
          }).toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final doc = categories[index];
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = _selectedCategory == doc.id;

              return ListTile(
                title: Text(data['name'],  style:  theme.textTheme.bodyMedium,),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCategory = doc.id;
                  });
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _selectedCategory == null
              ? null
              : () {
                  Navigator.pop(context, _selectedCategory);
                },
          label: Text(AppLocalizations.of(context)!.select),
          icon: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}
