import 'package:econance/features/graphs/pages/graphs_page.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:econance/theme/responsive_colors.dart';
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
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.primaryColor,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              if (canChangeRole)
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(AppLocalizations.of(context)!.changeRole, style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showChangedRoleDialog(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text(AppLocalizations.of(context)!.viewMemberGraphs, style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    showDragHandle: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    context: context,
                    builder: (ctx) => GraphsPage(uid: memberUid, hideSensitive: false),
                  );
                },
              ),
              if (canRemove)
                ListTile(
                  leading: Icon(Icons.delete, color: ResponsiveColors.error(Theme.of(context))),
                  title: Text(AppLocalizations.of(context)!.removeFromFamily, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ResponsiveColors.error(Theme.of(context)))),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final ok = await showDialog(
                      context: context,
                      builder: (dC) => AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        title: Text(AppLocalizations.of(context)!.removeMemberTitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        content: Text(AppLocalizations.of(context)!.removeMemberContent),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dC, false), child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: ResponsiveColors.whiteOpacity(Theme.of(context), 0.7)))),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dC, true),
                            child: Text(AppLocalizations.of(context)!.remove, style: TextStyle(color: ResponsiveColors.onPrimary(Theme.of(context)))),
                            style: ElevatedButton.styleFrom(backgroundColor: ResponsiveColors.error(Theme.of(context))),
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
          backgroundColor: Theme.of(context).cardColor,
          title: Text(AppLocalizations.of(context)!.changeRole, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            value: selected,
            style: Theme.of(context).textTheme.bodyMedium,
            items: [
              if (currentUserRole == 'creator' || currentUserRole == 'admin')
                DropdownMenuItem(value: 'admin', child: Text(AppLocalizations.of(context)!.admin)),
              if (currentUserRole == 'creator' || currentUserRole == 'admin')
                DropdownMenuItem(value: 'member', child: Text(AppLocalizations.of(context)!.member)),
            ],
            onChanged: (v) => selected = v ?? role,
          ),
            actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: ResponsiveColors.error(Theme.of(context))))),
            ElevatedButton(
              onPressed: () async {
                await FamilyService().changeMemberRole(familyId, memberUid, selected);
                Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
}
