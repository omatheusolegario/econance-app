import 'package:econance/features/family/family_main_screen.dart';
import 'package:flutter/material.dart';

import '../../services/family_service.dart';
import 'user_invites_list.dart';

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
  late String? _familyId = widget.familyId;
  late String? _role = widget.role;

  final _fs = FamilyService();

  Future<void> _createFamilyFlow() async {
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900.withValues(alpha: 1),
        title: Text(
          "Create Family",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: "Family name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (ok == true && controller.text.trim() != '') {
      final fId = await _fs.createFamily(name: controller.text.trim());
      setState(() {
        _familyId = fId;
        _role = "admin";
      });
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (ctx) => FamilyMainScreenPage()));

    } else if (ok == true && controller.text.trim() == ''){
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Family name can't be empty")));
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
                color: Colors.white60,
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
                        label: const Text("Create family"),
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
