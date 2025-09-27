import 'package:econance/add_category.dart';
import 'package:econance/revenues_expenses..dart';
import 'package:flutter/material.dart';
import 'home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isExpanded = false;

  final List<Widget> _pages = [
    const HomePage(),
    const RevenuesExpensesPage(),
    const AddCategoryPage(),
  ];

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double bottomHeight = isExpanded ? 350 : 80;

    Widget _buildMenuItem(
      IconData icon,
      String label,
      GestureTapCallback onTap,
    ) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: theme.scaffoldBackgroundColor, size: 28),
              const SizedBox(width: 18),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    Widget _buildNavButton(IconData icon, int index) {
      return InkWell(
        onTap: () => _onTabTap(index),
        child: Icon(icon, color: theme.scaffoldBackgroundColor, size: 28),
      );
    }

    void _closeIfExpanded() {
      if (isExpanded) {
        setState(() => isExpanded = false);
      }
    }

    return GestureDetector(
      onTap: _closeIfExpanded,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
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
                                    () => _onTabTap(1),
                                  ),
                                  _buildMenuItem(
                                    Icons.dashboard,
                                    "Dashboard",
                                    () => _onTabTap(0),
                                  ),
                                  _buildMenuItem(
                                    Icons.qr_code_scanner,
                                    "Scan Bill",
                                    () => _onTabTap(1),
                                  ),
                                  _buildMenuItem(
                                    Icons.sell,
                                    "Categories",
                                    () => _onTabTap(2),
                                  ),
                                  _buildMenuItem(
                                    Icons.family_restroom,
                                    "Family",
                                    () => _onTabTap(1),
                                  ),
                                  _buildMenuItem(
                                    Icons.settings,
                                    "Settings",
                                    () => _onTabTap(1),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNavButton(Icons.dashboard, 0),
                              _buildNavButton(Icons.qr_code_scanner, 1),

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
                              _buildNavButton(Icons.bar_chart_sharp, 1),
                              _buildNavButton(Icons.pie_chart_sharp, 2),
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
