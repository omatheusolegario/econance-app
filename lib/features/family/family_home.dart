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
  late String? _role = widget.role;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Here you can manage",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
            Text(
              "Family members",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fs.membersStream(_familyId!),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final members = snap.data!.docs;
                  return ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final m = members[i];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getUserInfo(m.id),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData) {
                            return const ListTile(
                              title: Text('Carregando...'),
                            );
                          }

                          final userData = userSnap.data!;
                          return MemberCard(
                            familyId: _familyId!,
                            memberUid: m.id,
                            displayName: userData['fullName'],
                            email: userData['email'],
                            role: m['role'] ?? 'member',
                            isAdminView: _role == "admin",
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
