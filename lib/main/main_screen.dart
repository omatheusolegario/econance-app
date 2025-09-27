import 'package:econance/features/categories/add_category.dart';
import 'package:econance/features/categories/categories.dart';
import 'package:econance/features/transactions/revenues_expenses..dart';
import 'package:flutter/material.dart';
import '../features/home/home.dart';

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
  ];

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddModal(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 12, right: 12),
        child: Container(
        decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.black),
                title: Text("Manage Revenue/Expense", style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _onTabTap(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.black),
                title: Text("Dashboard", style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _onTabTap(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: Colors.black),
                title: Text("Scan Bill", style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _onTabTap(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell, color: Colors.black),
                title: Text("Categories", style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _onTabTap(3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.family_restroom, color: Colors.black),
                title: Text("Family", style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _onTabTap(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.black),
                title: Text("Settings", style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _onTabTap(2);
                },
              ),
            ],
          ),
      ),

        ),
    );
  }

  void _toggleHide(){
    setState(() {
      _hideSensitive = !_hideSensitive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double bottomHeight = 80;

    Widget _buildNavButton(IconData icon, int index) {
      return InkWell(
        onTap: () => _onTabTap(index),
        child: Icon(icon, color: theme.scaffoldBackgroundColor, size: 28),
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
            IconButton(onPressed: (){}, icon: const Icon(Icons.account_circle, size: 32, color: Colors.white)),
            IconButton(onPressed: _toggleHide, icon: Icon(_hideSensitive ? Icons.visibility_off : Icons.visibility, color: Colors.white,))
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
              color: theme.primaryColor,
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5CB37F),
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
