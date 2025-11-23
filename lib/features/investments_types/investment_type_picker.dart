import 'package:flutter/material.dart';
import 'package:econance/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/theme/responsive_colors.dart';

class InvestmentTypePickerPage extends StatefulWidget {
  final String uid;

  const InvestmentTypePickerPage({super.key ,required this.uid,});

  @override
  State<InvestmentTypePickerPage> createState() =>
      _InvestmentTypePickerPageState();
}

class _InvestmentTypePickerPageState extends State<InvestmentTypePickerPage> {
  String _search = "";
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchInvestmentTypesHint,
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
            .doc(widget.uid)
            .collection('investments_types')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final types = snapshot.data!.docs.where((doc) {
            final name = (doc['name'] as String).toLowerCase();
            return name.contains(_search);
          }).toList();

          if (types.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noTypesFoundAddOne));
          }

          return ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              final doc = types[index];
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = _selectedType == doc.id;

              return ListTile(
                title: Text(data['name'], style: theme.textTheme.bodyMedium),
                trailing: isSelected
                    ? Icon(Icons.check, color: ResponsiveColors.success(theme))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedType = doc.id;
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
          onPressed: _selectedType == null
              ? null
              : () async {
                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('investments_types')
                      .doc(_selectedType!)
                      .get();

                  if (doc.exists) {
                    final name = doc['name'];
                    if (!mounted) return;
                    Navigator.pop(context, name);
                  }
                },
          icon: const Icon(Icons.arrow_forward),
          label: Text(AppLocalizations.of(context)!.select),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
          ),
        ),
      ),
    );
  }
}
