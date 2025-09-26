import 'package:flutter/material.dart';
import 'theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isExpanded = false;
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/welcome-page",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);

    final double bottomHeight = isExpanded ? 300 : 80;

    Widget _buildMenuItem(IconData icon, String label) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.scaffoldBackgroundColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodyMedium),
        ],

      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
          ),

        ],
        title: const Text("Home"),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text(
                    "Você está na home, não se assuste, se quiser sair tem que limpar o cache ou apertar o botao de voltar Kkkkk",
                  ),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, "/revenues-expenses"), child: Text("Revenues-expenses")),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, "/add-category"), child: Text("Category")),
                  const SizedBox(height: 120),

                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomHeight,
            child: Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() => isExpanded = !isExpanded);
                    },
                  ),
                  if (isExpanded)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildMenuItem(Icons.add, "Manage Revenue"),
                          _buildMenuItem(Icons.dashboard, "Dashboard"),
                          _buildMenuItem(Icons.qr_code, "Scan Bill"),
                          _buildMenuItem(Icons.show_chart, "Investments"),
                          _buildMenuItem(Icons.list, "Transactions"),
                          _buildMenuItem(Icons.settings, "Settings"),
                        ],
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.dashboard, color: theme.primaryColor),
                        Icon(Icons.qr_code, color: theme.primaryColor),
                        Icon(
                          Icons.add_circle,
                          size: 36,
                          color: theme.primaryColor,
                        ),
                        Icon(Icons.show_chart, color: theme.primaryColor),
                      ],
                    ),
                  if (isExpanded)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildMenuItem(Icons.add, "Manage Revenue"),
                          _buildMenuItem(Icons.dashboard, "Dashboard"),
                          _buildMenuItem(Icons.qr_code, "Scan Bill"),
                          _buildMenuItem(Icons.show_chart, "Investments"),
                          _buildMenuItem(Icons.list, "Transactions"),
                          _buildMenuItem(Icons.settings, "Settings"),
                        ],
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.dashboard,
                          color: theme.scaffoldBackgroundColor,
                        ),
                        Icon(
                          Icons.qr_code,
                          color: theme.scaffoldBackgroundColor,
                        ),
                        Icon(
                          Icons.add_circle,
                          size: 36,
                          color: theme.scaffoldBackgroundColor,
                        ),
                        Icon(
                          Icons.show_chart,
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
