import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/services/family_service.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:econance/theme/responsive_colors.dart';

class FamilyInvitesList extends StatelessWidget {
  final String familyId;
  final String role;
  final FamilyService _familyService = FamilyService();

  FamilyInvitesList({super.key, required this.familyId, required this.role});

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = ResponsiveColors.greyShade(theme, theme.brightness == Brightness.dark ? 800 : 300);
    final highlightColor = ResponsiveColors.greyShade(theme, theme.brightness == Brightness.dark ? 600 : 100);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 4, top: 4, left: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
                    leading: CircleAvatar(backgroundColor: baseColor, radius: 20),
            title: Container(height: 16, width: 120, color: baseColor, margin: const EdgeInsets.symmetric(vertical: 4)),
            subtitle: Container(height: 14, width: 180, color: baseColor, margin: const EdgeInsets.symmetric(vertical: 2)),
            trailing: Container(height: 20, width: 20, color: baseColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _familyService.streamFamilyPendingInvites(familyId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildShimmer(context);
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noPendingInvites,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
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
                if (!userSnap.hasData) return _buildShimmer(context);
                final invitedName =
                    userSnap.data?['personalInfo']['fullName'] ?? 'Unknown';

                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 4, top: 4, left: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: inviteData['status'] == 'pending'
                        ? Text(
                      AppLocalizations.of(context)!.waitingResponseFrom,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    )
                        : inviteData['status'] == 'declined'
                        ? Text(
                      AppLocalizations.of(context)!.declinedInvite,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ResponsiveColors.error(Theme.of(context))),
                    )
                        : Text(
                      AppLocalizations.of(context)!.acceptedInvite,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ResponsiveColors.success(Theme.of(context))),
                    ),
                    subtitle: Text(
                      "$invitedName",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: role == 'admin' || role == 'creator'
                        ? IconButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.deletedInvite)),
                        );
                        await FirebaseFirestore.instance
                            .collection('families')
                            .doc(familyId)
                            .collection('invites')
                            .doc(invites[index].id)
                            .delete();
                      },
                      icon: Icon(Icons.close, color: ResponsiveColors.greyShade(Theme.of(context), 400)),
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
