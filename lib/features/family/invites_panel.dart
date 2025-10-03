import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/services/family_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitesList extends StatelessWidget {
  final FamilyService _familyService = FamilyService();

  InvitesList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _familyService.streamMyInvites(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(child: Text("No pending invites"));
        }

        final invites = snap.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invites.length,
          itemBuilder: (context, index) {
            final invite = invites[index];
            final data = invite.data() as Map<String, dynamic>? ?? {};
            final inviterName = data['inviterName'] ?? 'Someone';
            final familyId = invite.reference.parent.parent!.id;

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('families')
                  .doc(familyId)
                  .snapshots(),
              builder: (ctx, familySnap) {
                if (!familySnap.hasData) return const SizedBox.shrink();
                final familyName = familySnap.data?['name'] ?? 'a family';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text("$inviterName invited you to $familyName"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await _familyService.respondToInvite(
                              familyId,
                              true,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Invite accepted, joined family",
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () async {
                            await _familyService.respondToInvite(
                              familyId,
                              false,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Invite declined")),
                              );
                            }
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
