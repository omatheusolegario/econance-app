import 'package:econance/features/graphs/pages/graphs_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/family_service.dart';
import '../graphs/widgets/balance_chart_card.dart';

class MemberCard extends StatelessWidget {
  final String familyId;
  final String memberUid;
  final String displayName;
  final String email;
  final String role;
  final bool isAdminView;
  final VoidCallback? onRemoved;

  const MemberCard({
    super.key,
    required this.familyId,
    required this.memberUid,
    required this.displayName,
    required this.email,
    required this.role,
    this.isAdminView = false,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GraphsPage(uid: memberUid)),
        );
      },
      leading: CircleAvatar(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        ),
      ),
      title: Text(displayName.isNotEmpty ? displayName : email),
      subtitle: Text("$email • ${role.toUpperCase()}"),
      trailing: isAdminView
          ? IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _openAdminActions(context),
            )
          : null,
    );
  }

  void _openAdminActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text("Change role"),
                onTap: () {
                  Navigator.pop(ctx);
                  _showChangedRoleDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Remove from family",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog(
                    context: context,
                    builder: (dC) => AlertDialog(
                      title: const Text("Remove member?"),
                      content: const Text(
                        "Are you sure you want to remove this member?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dC, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dC, true),
                          child: const Text("Remove"),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await FamilyService().removeMember(familyId, memberUid);
                    if (onRemoved != null) onRemoved!();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text("View member graphs"),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GraphsPage(uid: memberUid),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangedRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String selected = role;
        return AlertDialog(
          title: const Text("Change role"),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'member', child: Text('Member')),
            ],
            onChanged: (v) {
              selected = v ?? 'member';
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FamilyService().changeMemberRole(
                  familyId,
                  memberUid,
                  selected,
                );
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
