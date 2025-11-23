import 'package:flutter/material.dart';
import 'package:econance/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/theme/responsive_colors.dart';
import 'edit_investment_type.dart';

class InvestmentTypesPage extends StatefulWidget {
  final String uid;
  const InvestmentTypesPage({super.key, required this.uid});

  @override
  State<InvestmentTypesPage> createState() => _InvestmentTypesPageState();
}

class _InvestmentTypesPageState extends State<InvestmentTypesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: ResponsiveColors.greyShade(theme, 400),
                        borderRadius: BorderRadius.circular(2),
                      ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.organizeYourInvestmentsBy,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ResponsiveColors.whiteOpacity(theme, 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context)!.investmentTypes,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('investments_types')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final types = snapshot.data!.docs;
                    if (types.isEmpty) {
                      return Center(
                        child: Text(AppLocalizations.of(context)!.noInvestmentTypesYet),
                      );
                    }
                    return ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: types.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              data['name'],
                              style: theme.textTheme.bodyMedium,
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25),
                                  ),
                                ),
                                builder: (context) => EditInvestmentTypePage(
                                  uid: widget.uid, // use widget.uid
                                  typeId: doc.id,
                                  initialName: data['name'],
                                ),
                              );
                            },
                          );
                        }),
                      ).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
