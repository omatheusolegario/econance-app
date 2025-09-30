import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/theme/theme_manager.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final divider = Divider(
      color: Colors.white.withOpacity(0.3),
      thickness: 1,
      height: 1,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(themeManager.isDark ? 'Dark mode' : 'Light mode'),
            trailing: Switch(
              value: themeManager.isDark,
              onChanged: (value) => themeManager.toggleTheme(),
              activeColor: Theme.of(context).primaryColor,
              activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
          divider,
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('About us'),
            subtitle: Text('Learn more about Econance'),
          ),
          divider,
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
