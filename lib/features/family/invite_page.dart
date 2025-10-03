import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/features/family/invites_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/family_service.dart';

class InvitePage extends StatefulWidget {
  final String? familyId;
  const InvitePage({super.key, required this.familyId});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  late String? _familyId = widget.familyId;
  final _auth = FirebaseAuth.instance;
  final _fs = FamilyService();

  void _showInviteDialog() {
    final emailCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Invite member"),
        content: TextField(
          controller: emailCtl,
          decoration: const InputDecoration(hintText: "member@example.com"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
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
    return Scaffold(
      body: Column(
        children: [
          InvitesList(),
          _familyId != null ?
          ElevatedButton(onPressed: _showInviteDialog, child: Text("Invite"))
          : SizedBox.shrink(),
        ],
      ),
    );
  }
}
