import 'package:econance/features/family/family_ai_insights.dart';
import 'package:econance/features/family/family_create.dart';
import 'package:econance/features/family/family_home.dart';
import 'package:econance/features/family/invite_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/family_service.dart';
import 'member_card.dart';
import 'invites_panel.dart';

class FamilySpacePage extends StatefulWidget {
  const FamilySpacePage({super.key});

  @override
  State<FamilySpacePage> createState() => _FamilySpacePageState();
}

class _FamilySpacePageState extends State<FamilySpacePage> {
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
      return [FamilyCreatePage(familyId: null, role: null), InvitePage(familyId: null),];

    }
    return [
      FamilyHomePage(familyId: _familyId, role: _role),
      InvitePage(familyId: _familyId),
      FamilyAIInsightsPage(familyId: _familyId!),
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
        title: const Text("Leave Family?"),
        content: const Text("Are you sure you want to leave this family?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes"),
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
          title: const Text("Delete Family?"),
          content: const Text(
            "You are the last one in the family, leaving will delete it. Are you sure?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
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
              child: const Text("Delete Family"),
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
                ? theme.primaryColor.withValues(alpha: 0.2)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Space"),
        actions: [
          if (_role == "admin")
            PopupMenuButton(
              onSelected: (v) {
                if (v == "leave") _leaveFamily();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(child: Text("Leave Family"), value: "leave"),
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
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(31),
            ),

            child: _familyId != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildNavButton(Icons.dashboard, 0),
                      buildNavButton(Icons.qr_code_scanner, 1),
                      buildNavButton(Icons.pie_chart_sharp, 2),
                    ],
                  )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavButton(Icons.dashboard, 0),
                buildNavButton(Icons.qr_code_scanner, 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
