import 'package:econance/features/family/family_ai_insights.dart';
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

  String? _familyId;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserFamily();
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
    } else {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'personalInfo': {'familyId': FieldValue.delete()},
      }, SetOptions(merge: true));
      setState(() {
        _familyId = null;
        _role = null;
      });
    }
  }

  Future<void> _createFamilyFlow() async {
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create Family"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Family name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (ok == true && controller.text.trim().isNotEmpty) {
      final fId = await _fs.createFamily(name: controller.text.trim());
      setState(() {
        _familyId = fId;
        _role = "admin";
      });
    }
  }

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
                await _fs.inviteByUid(
                  invitedUid: invitedUid,
                  familyId: _familyId!,
                  inviterName: _auth.currentUser?.displayName ?? "Unknown",
                );

                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Invite sent")));
                }
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveFamily() async {
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

    if (_role == "admin") {
      final adminCount = await _fs.adminCount(_familyId!);
      if (adminCount <= 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Your are the last admin. Transfer admin rights first.",
              ),
            ),
          );
        }
        return;
      }
    }
    await _fs.removeMember(_familyId!, _auth.currentUser!.uid);

    setState(() {
      _familyId = null;
      _role = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_familyId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Family Space")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              InvitesList(),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("No family found", style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        "Create a family to share finances with others.",
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _createFamilyFlow,
                        icon: const Icon(Icons.group_add),
                        label: const Text("Create family"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Space"),
        actions: [
          if (_role == "admin")
            IconButton(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.person_add),
            ),
          PopupMenuButton(
            onSelected: (v) {
              if (v == "leave") _leaveFamily();
              if (v == "ai") {Navigator.push(context, MaterialPageRoute(builder: (context) => FamilyAIInsightsPage(familyId: _familyId!)));}
            },
            itemBuilder: (_) => const [
              PopupMenuItem(child: Text("Family AI Insights"), value: "ai"),
              PopupMenuItem(child: Text("Leave Family"), value: "leave"),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fs.membersStream(_familyId!),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final members = snap.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final m = members[i];
                    return MemberCard(
                      familyId: _familyId!,
                      memberUid: m.id,
                      displayName: m['displayName'] ?? '',
                      email: m['email'] ?? '',
                      role: m['role'] ?? 'member',
                      isAdminView: _role == "admin",
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
