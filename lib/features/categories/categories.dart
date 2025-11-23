import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
                AppLocalizations.of(context)!.separateExpensesInto,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context)!.categoriesTitle,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [
                    _buildCategorySection(
                      title: AppLocalizations.of(context)!.revenues,
                      type: "revenue",
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    _buildCategorySection(
                      title: AppLocalizations.of(context)!.expenses,
                      type: "expense",
                      color: Colors.red,
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

  /// Método auxiliar para renderizar seções de categorias
  Widget _buildCategorySection({
    required String title,
    required String type,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
              .where('type', isEqualTo: type)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No $title yet",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              );
            }

            final categories = snapshot.data!.docs;

            return Column(
              children: categories.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: theme.cardColor,
                  child: ListTile(
                    leading: Icon(
                      type == 'revenue'
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: color,
                    ),
                    title: Text(
                      data['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          builder: (context) => EditCategoryPage(
                            uid: uid,
                            categoryId: doc.id,
                            initialName: data['name'],
                            initialType: data['type'],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
