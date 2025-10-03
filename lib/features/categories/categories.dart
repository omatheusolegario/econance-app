import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_category.dart';

class CategoriesPage extends StatefulWidget {
  final String uid;
  const CategoriesPage({super.key, required this.uid});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final uid = widget.uid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Column(
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
              Text(
                "Separate your expenses into",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Categories",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [
                    Text(
                      "Revenues",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('categories')
                          .where('type', isEqualTo: 'revenue')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final categories = snapshot.data!.docs;
                        return Column(
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: categories.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(
                                  data['name'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                                      builder: (context) => EditCategoryPage(categoryId: doc.id, initialName: data['name'], initialType: data['type'])
                                  );
                                }
                                );
                            }),
                          ).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Expenses",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('categories')
                          .where('type', isEqualTo: 'expense')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final categories = snapshot.data!.docs;
                        return Column(
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: categories.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return ListTile(
                                  title: Text(
                                    data['name'],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                                        builder: (context) => EditCategoryPage(categoryId: doc.id, initialName: data['name'], initialType: data['type'])
                                    );
                                  }
                              );
                            }),
                          ).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
