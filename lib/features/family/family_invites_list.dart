import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/services/family_service.dart';
import 'package:flutter/material.dart';


class FamilyInvitesList extends StatelessWidget {
  final String familyId;
  final String role;
  final FamilyService _familyService = FamilyService();

  FamilyInvitesList({super.key, required this.familyId, required this.role});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _familyService.streamFamilyPendingInvites(familyId),
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
            final inviteData = invites[index];
            final invitedUid = inviteData['invitedUid'] ?? '';

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(invitedUid)
                  .snapshots(),
              builder: (ctx, userSnap) {
                if (!userSnap.hasData) return const SizedBox.shrink();
                final invitedName =
                    userSnap.data?['personalInfo']['fullName'] ?? 'Unknown';

                return Card(
                  color: Colors.grey.shade900,
                  margin: const EdgeInsets.only(bottom: 4, top: 4, left: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: inviteData['status'] == 'pending'
                        ? Text(
                            "Waiting response from",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.orange),
                          )
                        : inviteData['status'] == 'declined'
                        ? Text(
                            "Declined invite",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                          )
                        :  Text(
                            "Accepted invite",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.green),
                          ),

                    subtitle: Text(
                      "$invitedName",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: role == 'admin'
                        ? IconButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Deleted Invite")),
                              );
                              await FirebaseFirestore.instance
                                  .collection('families')
                                  .doc(familyId)
                                  .collection('invites')
                                  .doc(invites[index].id)
                                  .delete();
                            },
                            icon: Icon(Icons.close, color: Colors.grey),
                          )
                        : null,
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
