import 'dart:ui';
import 'package:econance/features/family/family_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/features/config/config.dart';

class AccountCard extends StatelessWidget {
  final String? photoUrl;
  const AccountCard({super.key, required this.photoUrl});

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {


      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final personalInfo = userDoc.data()?['personalInfo'] ?? {};
      final name = personalInfo['fullName'] ?? 'User';

      return {'name': name};
    } catch (e) {
      throw Exception('Failed to load user data');
    }
  }

  void _navigateToConfig(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Config()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildBlurWrapper(
            theme,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildBlurWrapper(
            theme,
            child: Center(
              child: Text(
                'Erro: ${snapshot.error ?? "Data not found"}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return _buildBlurWrapper(
          theme,
          child: _buildContent(theme, snapshot.data!, context),
        );
      },
    );
  }

  Widget _buildBlurWrapper(ThemeData theme, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildContent(
      ThemeData theme,
      Map<String, dynamic> data,
      BuildContext context,
      ) {
    final name = data['name'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(theme, name, context),
        const SizedBox(height: 16),
        const Divider(color: Colors.white54),
        const SizedBox(height: 16),
        _buildFamilySpaceTile(context, theme),
      ],
    );
  }

  Widget _buildHeaderRow(ThemeData theme, String name, BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.primaryColor,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : const AssetImage('assets/images/default_avatar.png')
        as ImageProvider,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _navigateToConfig(context),
        ),
      ],
    );
  }

  Widget _buildFamilySpaceTile( BuildContext ctx, ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.family_restroom, color: Colors.white),
      title: const Text("Family Space", style: TextStyle(color: Colors.white)),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (context) => FamilyMainScreenPage())),
    );
  }
}
