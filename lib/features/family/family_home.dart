import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/family_service.dart';
import 'member_card.dart';

class FamilyHomePage extends StatefulWidget{
  final String? familyId;
  final String? role;

  const FamilyHomePage({super.key, required this.familyId, required this.role});

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage>{
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late String? _familyId = widget.familyId;
  late String? _role = widget.role;
  final _fs = FamilyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  if (m.id != uid) {
                    return MemberCard(
                      familyId: _familyId!,
                      memberUid: m.id,
                      displayName: m['displayName'] ?? '',
                      email: m['email'] ?? '',
                      role: m['role'] ?? 'member',
                      isAdminView: _role == "admin",
                    );
                  }else{
                    return MemberCard(
                        familyId: _familyId!,
                        memberUid: m.id,
                        displayName: m['displayName'] ?? '',
                        email: m['email'] ?? '',
                        role: m['role'] ?? 'member'
                    );
                  }
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