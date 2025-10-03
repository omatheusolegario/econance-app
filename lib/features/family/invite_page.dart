import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/features/family/family_invites_list.dart';
import 'package:econance/features/family/invites_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: Colors.grey.shade900.withValues(alpha: 1),
        title: Text(
          "Invite member",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: emailCtl,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: const InputDecoration(hintText: "member@example.com"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.red.shade500)),
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
                    SnackBar(content: Text("No user found with this email")),
                  );
                  return;
                }
                final invitedUid = snap.docs.first.id;
                final invited = await _fs.inviteByUid(
                  invitedUid: invitedUid,
                  familyId: _familyId!,
                  inviterName: _auth.currentUser?.displayName ?? "Unknown",
                );

                Navigator.pop(ctx);
                if (invited) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Invite sent")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User already in a family")),
                  );
                }
              }
            },
            child: const Text("Invite"),
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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _familyId == null
                    ? Text(
                        "Participate in an existing family with",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                        ),
                      )
                    : Text(
                        "Invite new members to your family with",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                Text(
                  "Invites",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _familyId != null
                    ? FamilyInvitesList(familyId: _familyId!, role: _role!,)
                    : InvitesList(),
              ],
            ),

            _familyId != null
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showInviteDialog,
                      icon: Icon(Icons.person_add_alt_1),
                      label: Text("Invite new member"),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
