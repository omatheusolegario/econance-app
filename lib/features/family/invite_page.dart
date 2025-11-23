import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/features/family/family_invites_list.dart';
import 'package:econance/features/family/user_invites_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:econance/theme/responsive_colors.dart';

import '../../services/family_service.dart';

class InvitePage extends StatefulWidget {
  final String? familyId;
  final String? role;
  const InvitePage({super.key, required this.familyId, required this.role});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  late String? _familyId = widget.familyId;
  late String? _role = widget.role;
  final _auth = FirebaseAuth.instance;
  final _fs = FamilyService();

  void _showInviteDialog() {
    final emailCtl = TextEditingController();
    showDialog(
      context: context,
  builder: (ctx) => AlertDialog(
  backgroundColor: Theme.of(context).cardColor,
        title: Text(
          AppLocalizations.of(context)!.inviteMemberTitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: emailCtl,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.memberEmailHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: ResponsiveColors.error(Theme.of(context)))),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtl.text.trim();
              if (email.isNotEmpty && _familyId != null) {
                final snap = await FirebaseFirestore.instance
                    .collection('users')
                    .where('personalInfo.email', isEqualTo: email)
                    .limit(1)
                    .get();
                if (snap.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.noUserFoundWithThisEmail)),
                  );
                  return;
                }
                final invitedUid = snap.docs.first.id;
                final invited = await _fs.inviteByUid(
                  invitedUid: invitedUid,
                  familyId: _familyId!,
                  inviterName: _auth.currentUser?.displayName ?? AppLocalizations.of(context)!.unknown,
                );

                Navigator.pop(ctx);
                if (invited) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.inviteSent)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.userAlreadyInFamily)),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.invite),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _familyId == null
                    ? Text(
                        AppLocalizations.of(context)!.participateInExistingFamilyWith,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ResponsiveColors.whiteOpacity(theme, 0.6),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.inviteNewMembersToYourFamilyWith,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ResponsiveColors.whiteOpacity(theme, 0.6),
                        ),
                      ),
                Text(
                  AppLocalizations.of(context)!.invites,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _familyId != null
                    ? FamilyInvitesList(familyId: _familyId!, role: _role!,)
                    : UserInvitesList(),
              ],
            ),

            _familyId != null
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showInviteDialog,
                      icon: Icon(Icons.person_add_alt_1),
                      label: Text(AppLocalizations.of(context)!.inviteMemberTitle),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
