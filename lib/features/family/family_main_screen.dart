import 'package:econance/features/family/family_ai_insights.dart';
import 'package:econance/features/family/family_create.dart';
import 'package:econance/features/family/family_home.dart';
import 'package:econance/features/family/invite_page.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:econance/theme/responsive_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/family_service.dart';

class FamilyMainScreenPage extends StatefulWidget {
  const FamilyMainScreenPage({super.key});

  @override
  State<FamilyMainScreenPage> createState() => _FamilyMainScreenPageState();
}

class _FamilyMainScreenPageState extends State<FamilyMainScreenPage> {
  final _fs = FamilyService();
  final _auth = FirebaseAuth.instance;
  int _currentIndex = 0;

  String? _familyId;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserFamily();
  }

  List<Widget> get _pages {
    if (_familyId == null || _role == null) {
      return [
        FamilyCreatePage(familyId: null, role: null),
        InvitePage(familyId: null, role: null,),
      ];
    }
    return [
      FamilyHomePage(familyId: _familyId, role: _role),
      InvitePage(familyId: _familyId, role: _role,),
      FamilyAIInsightsPage(familyId: _familyId!, role: _role!),
    ];
  }

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadUserFamily() async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = userDoc.data();
    final fId = data?['personalInfo']?['familyId'] as String?;

    if (fId == null) {
      setState(() {
        _familyId = null;
        _role = null;
        _currentIndex = 0;
      });
      return;
    }

    final memberDoc = await FirebaseFirestore.instance
        .collection('families')
        .doc(fId)
        .collection('members')
        .doc(uid)
        .get();

    if (memberDoc.exists) {
      setState(() {
        _familyId = fId;
        _role = memberDoc['role'] as String?;
      });
    }
  }

  Future<void> _leaveFamily() async {
    final uid = _auth.currentUser!.uid;
    if (_familyId == null) return;

    final ok = await showDialog<bool>(
      context: context,
        builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
        title: Text(
          AppLocalizations.of(context)!.leaveFamilyTitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.leaveFamilyContent,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.no, style: TextStyle(color: ResponsiveColors.hint(Theme.of(context)))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ResponsiveColors.error(Theme.of(context)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: ResponsiveColors.onPrimary(Theme.of(context)))),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final totalMembers = await _fs.memberCount(_familyId!);

    if (ok == true && totalMembers == 1) {
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            AppLocalizations.of(context)!.deleteFamilyTitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteFamilyContent,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: ResponsiveColors.hint(Theme.of(context)))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ResponsiveColors.error(Theme.of(context)),
              ),
              onPressed: () async {
                Navigator.pop(ctx, true);
                await _fs.removeMember(
                  _familyId!,
                  _auth.currentUser!.uid,
                  true,
                );
                setState(() {
                  _familyId = null;
                  _role = null;
                });
                await _loadUserFamily();
              },
              child: Text(
                AppLocalizations.of(context)!.deleteFamily,
                style: TextStyle(color: ResponsiveColors.whiteOpacity(Theme.of(context), 1.0)),
              ),
            ),
          ],
        ),
      );
    } else if (ok == true) {
      await _fs.removeMember(_familyId!, _auth.currentUser!.uid, false);
      setState(() {
        _familyId = null;
        _role = null;
      });
      await _loadUserFamily();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double bottomHeight = 80;

    Widget buildNavButton(IconData icon, int index) {
      final bool isSelected = _currentIndex == index;
      return InkWell(
        onTap: () => _onTabTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
          color: isSelected
            ? theme.primaryColor.withOpacity(0.2)
            : ResponsiveColors.transparent(),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          if (_familyId != null)
            PopupMenuButton(
              borderRadius: BorderRadius.circular(50),
              icon: Icon(Icons.exit_to_app_rounded),
              onSelected: (v) {
                if (v == "leave") _leaveFamily();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text(
                    AppLocalizations.of(context)!.leaveFamily,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ResponsiveColors.error(theme),
                    ),
                  ),
                  value: "leave",
                ),
              ],
            ),
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.translucent,
          child: AnimatedContainer(
            margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: bottomHeight,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(31),
            ),

            child: _familyId != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildNavButton(Icons.dashboard, 0),
                      buildNavButton(Icons.email_outlined, 1),
                      buildNavButton(Icons.pie_chart_sharp, 2),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildNavButton(Icons.dashboard, 0),
                      buildNavButton(Icons.email_outlined, 1),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
