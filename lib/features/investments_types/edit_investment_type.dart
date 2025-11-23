import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/theme/responsive_colors.dart';

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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.typeUpdated)),
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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.typeDeleted)),
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
                    color: ResponsiveColors.greyShade(theme, 400),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(AppLocalizations.of(context)!.nameLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 7),
            TextField(
              controller: _nameController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.exampleStocksHint),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateType,
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ResponsiveColors.error(theme),
                    ),
                    onPressed: _deleteType,
                    child: Text(AppLocalizations.of(context)!.delete),
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
