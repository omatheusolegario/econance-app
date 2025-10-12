import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/family_service.dart';
import 'member_card.dart';

class FamilyHomePage extends StatefulWidget {
  final String? familyId;
  final String? role;

  const FamilyHomePage({super.key, required this.familyId, required this.role});

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late String? _familyId = widget.familyId;
  late String? _role = widget.role?.toLowerCase();
  final _fs = FamilyService();

  Future<Map<String, dynamic>> _getUserInfo(String memberUid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(memberUid).get();
    final data = doc.data() ?? {};
    final personalInfo = data['personalInfo'] as Map<String, dynamic>? ?? {};
    return {
      'fullName': personalInfo['fullName'] ?? '',
      'email': personalInfo['email'] ?? '',
    };
  }

  List<Map<String, dynamic>> sortMembers(String currentUserUid, List<Map<String, dynamic>> members) {
    List<Map<String, dynamic>> currentUser = [];
    List<Map<String, dynamic>> creator = [];
    List<Map<String, dynamic>> admins = [];
    List<Map<String, dynamic>> regularMembers = [];

    for (var member in members) {
      if (member['uid'] == currentUserUid) {
        currentUser.add(member);
      } else if (member['role'] == 'creator') {
        creator.add(member);
      } else if (member['role'] == 'admin') {
        admins.add(member);
      } else {
        regularMembers.add(member);
      }
    }

    int alphaSort(Map<String, dynamic> a, Map<String, dynamic> b) {
      return (a['displayName'] as String)
          .toLowerCase()
          .compareTo((b['displayName'] as String).toLowerCase());
    }

    currentUser.sort(alphaSort);
    creator.sort(alphaSort);
    admins.sort(alphaSort);
    regularMembers.sort(alphaSort);

    return [...currentUser, ...creator, ...admins, ...regularMembers];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    print("Current user role: $_role");

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Here you can manage",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
            ),
            Text(
              "Family members",
              style: theme.textTheme.headlineLarge
                  ?.copyWith(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fs.membersStream(_familyId!),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final membersDocs = snap.data!.docs;

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: Future.wait(
                      membersDocs.map((m) async {
                        final userInfo = await _getUserInfo(m.id);
                        return {
                          'uid': m.id,
                          'role': (m['role'] ?? 'member').toLowerCase(),
                          'displayName': userInfo['fullName'],
                          'email': userInfo['email'],
                        };
                      }),
                    ),
                    builder: (context, membersSnap) {
                      if (!membersSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final membersList = membersSnap.data!;
                      final sortedMembers = sortMembers(uid, membersList);

                      return ListView.separated(
                        itemCount: sortedMembers.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final member = sortedMembers[i];

                          return MemberCard(
                            familyId: _familyId!,
                            memberUid: member['uid'],
                            displayName: member['displayName'],
                            email: member['email'],
                            role: member['role'],
                            isAdminView: _role == "admin" || _role == "creator",
                            currentUserUid: uid,
                            currentUserRole: _role ?? 'member',
                            onRemoved: () {
                              setState(() {});
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
