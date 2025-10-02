import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/services/family_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitesList extends StatelessWidget {
  const InvitesList({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser!.email!;
    final stream = FirebaseFirestore.instance
        .collection('invites')
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final docs = snap.data!.docs;

        if (docs.isNotEmpty) return const SizedBox.shrink();
        return Column(
          children: docs.map((d) {
            final familyRef = d.reference.parent.parent;
            final familyId = familyRef!.id;
            final inviter = d['invitedByUid'];
            return Card(
              child: ListTile(
                title: Text(
                  "${inviter ?? 'Someone'} invited you to their family",
                ),
                subtitle: Text("Family: $familyId"),
                trailing: Wrap(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await FamilyService().acceptInvite(
                          inviteDocPath: d.reference.path,
                          familyId: familyId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Joined family")),
                        );
                      },
                      child: const Text("Accept"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FamilyService().declineInvite(d.reference.path);
                      },
                      child: const Text("Decline"),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
