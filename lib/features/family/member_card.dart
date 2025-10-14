import 'package:econance/features/graphs/pages/graphs_page.dart';
import 'package:flutter/material.dart';
import '../../services/family_service.dart';

class MemberCard extends StatelessWidget {
  final String familyId;
  final String memberUid;
  final String displayName;
  final String email;
  final String role;
  final bool isAdminView;
  final String currentUserUid;
  final String currentUserRole;
  final VoidCallback? onRemoved;
  final String? photoUrl;

  const MemberCard({
    super.key,
    required this.familyId,
    required this.memberUid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.photoUrl,
    this.isAdminView = false,
    required this.currentUserUid,
    required this.currentUserRole,
    this.onRemoved,
  });

  bool get isCreator => role == 'creator';
  bool get isCurrentUser => memberUid == currentUserUid;

  bool get canShowGear {
    if (!isAdminView) return false;
    if (currentUserRole == 'creator') return true;
    if (currentUserRole == 'admin' && !isCreator) return true;
    return false;
  }

  bool get canChangeRole {
    if (isCurrentUser) return false;
    if (currentUserRole == 'creator') return true;
    if (currentUserRole == 'admin' && !isCreator) return true;
    return false;
  }

  bool get canRemove {
    if (currentUserRole == 'creator') return true;
    if (currentUserRole == 'admin' && !isCreator) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar( radius: 24,
        backgroundColor: theme.primaryColor,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : const AssetImage('assets/images/default_avatar.png')
        as ImageProvider,
      ),
      title: Text(displayName.isNotEmpty ? displayName : email, style: theme.textTheme.bodyLarge),
      subtitle: Text("$email\n${role.toUpperCase()}"),
      trailing: canShowGear
          ? IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => _openAdminActions(context),
      )
          : null,
    );
  }

  void _openAdminActions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade900,
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              if (canChangeRole)
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
                title: Text("View member graphs", style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    showDragHandle: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    context: context,
                    builder: (ctx) => GraphsPage(uid: memberUid, hideSensitive: true),
                  );
                },
              ),
              if (canRemove)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text("Remove from family", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final ok = await showDialog(
                      context: context,
                      builder: (dC) => AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        title: Text("Remove member?", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        content: const Text("Are you sure you want to remove this member?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dC, false), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dC, true),
                            child: const Text("Remove", style: TextStyle(color: Colors.white)),
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
          title: Text("Change role", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            value: selected,
            style: Theme.of(context).textTheme.bodyMedium,
            items: [
              if (currentUserRole == 'creator' || currentUserRole == 'admin')
                DropdownMenuItem(value: 'admin', child: const Text('Admin')),
              if (currentUserRole == 'creator' || currentUserRole == 'admin')
                DropdownMenuItem(value: 'member', child: const Text('Member')),
            ],
            onChanged: (v) => selected = v ?? role,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: TextStyle(color: Colors.red.shade500))),
            ElevatedButton(
              onPressed: () async {
                await FamilyService().changeMemberRole(familyId, memberUid, selected);
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
