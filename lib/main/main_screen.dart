import 'dart:ui';
import 'package:econance/features/categories/add_category.dart';
import 'package:econance/features/categories/categories.dart';
import 'package:econance/features/config/config.dart';
import 'package:econance/features/transactions/revenues_expenses..dart';
import 'package:flutter/material.dart';
import '../features/home/home.dart';
import 'package:econance/cards/account_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _hideSensitive = false;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const RevenuesExpensesPage(),
    const AddCategoryPage(),
    const CategoriesPage(),
    const Config(),
  ];

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  void _openAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            padding: const EdgeInsets.only(bottom: 30, left: 12, right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(
                    "Manage Revenue/Expense",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: Text(
                    "Dashboard",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: Text(
                    "Scan Bill",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sell),
                  title: Text(
                    "Categories",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(3);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleHide() {
    setState(() {
      _hideSensitive = !_hideSensitive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double bottomHeight = 80;

    Widget _buildNavButton(IconData icon, int index) {
      final bool isSelected = _currentIndex == index;
      return InkWell(
        onTap: () => _onTabTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.2)
                : Colors.transparent,
            shape: BoxShape
                .circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.8,
                      child: const AccountCard(),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.account_circle,
                size: 32,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _toggleHide,
              icon: Icon(
                _hideSensitive ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
              color: theme.scaffoldBackgroundColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(31),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavButton(Icons.dashboard, 0),
                _buildNavButton(Icons.qr_code_scanner, 1),
                GestureDetector(
                  onTap: () => _openAddModal(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
                _buildNavButton(Icons.bar_chart_sharp, 1),
                _buildNavButton(Icons.pie_chart_sharp, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
