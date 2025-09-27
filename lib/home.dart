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

  void _closeIfExpanded() {
    if (isExpanded) {
      setState(() => isExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);

    final double bottomHeight = isExpanded ? 350 : 80;

    Widget _buildMenuItem(
      IconData icon,
      String label,
      VoidCallback onTap,
    ) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.scaffoldBackgroundColor,
                size: 28,
              ),
              const SizedBox(width: 18),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _closeIfExpanded,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout),
            ),
          ],
          title: const Text("Home"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const Text(
                  "Você está na home, não se assuste, se quiser sair tem que limpar o cache ou apertar o botao de voltar Kkkkk",
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, "/revenues-expenses"),
                  child: const Text("Revenues-expenses"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, "/add-category"),
                  child: const Text("Category"),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),

        bottomNavigationBar: SafeArea(
          child: GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: bottomHeight,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(31),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: isExpanded
                        ? SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: bottomHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildMenuItem(
                                    Icons.add,
                                    "Manage Revenue / Expense",
                                        () {
                                      Navigator.pushNamed(context, "/revenues-expenses");
                                    },
                                  ),
                                  _buildMenuItem(
                                    Icons.dashboard,
                                    "Dashboard",
                                        () {
                                      Navigator.pushNamed(context, "/dashboard");
                                    },
                                  ),
                                  _buildMenuItem(
                                    Icons.qr_code_scanner,
                                    "Scan Bill",
                                        () {
                                      Navigator.pushNamed(context, "/scan-bill");
                                    },
                                  ),
                                  _buildMenuItem(
                                    Icons.sell,
                                    "Categories",
                                        () {
                                      Navigator.pushNamed(context, "/add-category");
                                    },
                                  ),
                                  _buildMenuItem(
                                    Icons.family_restroom,
                                    "Family",
                                        () {
                                      Navigator.pushNamed(context, "/family");
                                    },
                                  ),
                                  _buildMenuItem(
                                    Icons.settings,
                                    "Settings",
                                        () {
                                      Navigator.pushNamed(context, "/config");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.dashboard,
                                color: theme.scaffoldBackgroundColor,
                              ),
                              Icon(
                                Icons.qr_code_scanner,
                                color: theme.scaffoldBackgroundColor,
                              ),

                              GestureDetector(
                                onTap: () =>
                                    setState(() => isExpanded = !isExpanded),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF5CB37F),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.bar_chart_sharp,
                                size: 36,
                                color: theme.scaffoldBackgroundColor,
                              ),
                              Icon(
                                Icons.pie_chart_sharp,
                                color: theme.scaffoldBackgroundColor,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
