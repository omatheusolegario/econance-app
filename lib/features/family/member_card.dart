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
        showModalBottomSheet(context: context, builder: (ctx) => GraphsPage(uid: memberUid));
      },
      leading: CircleAvatar(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        ),
      ),
      title: Text(displayName.isNotEmpty ? displayName : email,   style: theme.textTheme.bodyLarge),
      subtitle: Text("$email\n${role.toUpperCase()}",),
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
      backgroundColor: Colors.grey.shade900.withValues(alpha: 1),
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text("Change role", style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _showChangedRoleDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text("View member graphs", style: Theme.of(context).textTheme.bodyMedium,),
                onTap: () {
                  showModalBottomSheet(context: context, builder: (ctx) => GraphsPage(uid: memberUid));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  "Remove from family",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog(
                    context: context,
                    builder: (dC) => AlertDialog(
                      backgroundColor: Colors.grey.shade900,
                      title: Text("Remove member?", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
                      content: const Text(
                        "Are you sure you want to remove this member?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dC, false),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white70),),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dC, true),
                          child: const Text("Remove", style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await FamilyService().removeMember(familyId, memberUid, false);
                    if (onRemoved != null) onRemoved!();
                  }
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
          backgroundColor: Colors.grey.shade900,
          title: Text("Change role",style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            style:  Theme.of(context).textTheme.bodyMedium ,
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
              child: Text("Cancel", style: TextStyle(color: Colors.red.shade500),),
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
