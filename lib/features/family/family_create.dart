import 'package:econance/features/family/family_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:econance/theme/responsive_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/family_service.dart';

class FamilyCreatePage extends StatefulWidget {
  final String? familyId;
  final String? role;

  const FamilyCreatePage({
    super.key,
    required this.familyId,
    required this.role,
  });

  @override
  State<FamilyCreatePage> createState() => _FamilyCreatePageState();
}

class _FamilyCreatePageState extends State<FamilyCreatePage> {


  final _fs = FamilyService();

  Future<void> _createFamilyFlow() async {
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            AppLocalizations.of(context)!.createFamilyTitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.familyNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ResponsiveColors.error(theme)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        );
      },
    );

    if (ok == true && controller.text.trim() != '') {
  await _fs.createFamily(name: controller.text.trim());
  setState(() {});
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => FamilyMainScreenPage()));

    } else if (ok == true && controller.text.trim() == ''){
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.familyNameCantBeEmpty)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create or manage your own",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ResponsiveColors.whiteOpacity(theme, 0.6),
              ),
            ),
            Text(
              "Family",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20,),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "No family found",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create a family to share finances with others.",
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createFamilyFlow,
                        icon: const Icon(Icons.group_add),
                        label: Text(AppLocalizations.of(context)!.create),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
