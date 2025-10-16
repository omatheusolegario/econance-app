import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/features/ai/pages/ai_insights_page.dart';
import 'package:econance/features/graphs/pages/graphs_page.dart';
import 'package:econance/features/categories/add_category.dart';
import 'package:econance/features/categories/categories.dart';
import 'package:econance/features/config/config.dart';
import 'package:econance/features/ocr/pages/invoice.dart';
import 'package:econance/features/transactions/add_transaction.dart';
import 'package:econance/features/transactions/revenues_expenses.dart';
import 'package:flutter/material.dart';
import '../features/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econance/cards/account_card.dart';
import 'package:econance/features/investments/add_investment_page.dart';
import 'package:econance/features/investments_types/add_investment_type.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _photoUrl;

  bool _hideSensitive = true;
  int _currentIndex = 0;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage(hideSensitive: _hideSensitive);
      case 1:
        return RevenuesExpensesPage(uid: uid);
      case 2:
        return const AddCategoryPage();
      case 3:
        return CategoriesPage(uid: uid);
      case 4:
        return const Config();
      case 5:
        return const AddTransactionPage(type: "revenue");
      case 6:
        return const AddTransactionPage(type: "expense");
      case 7:
        return GraphsPage(uid: uid, hideSensitive: _hideSensitive);
      case 8:
        return const InvoicePage();
      case 9:
        return const AiInsightsPage();
      case 10:
        return AddInvestmentPage(uid: uid);
      case 11:
        return AddInvestmentTypePage();
      default:
        return HomePage(hideSensitive: _hideSensitive);
    }
  }

  Future<void> _loadPhoto() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data()?['personalInfo'];

    setState(() {
      _photoUrl = data?['photoUrl'] ?? user.photoURL ?? '';
    });
  }

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
            color: Theme.of(context).cardColor,
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
                  leading: const Icon(Icons.sell),
                  title: Text(
                    "New Category",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text(
                    "New Expense",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(6);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.wallet),
                  title: Text(
                    "New Revenue",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(5);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text(
                    "New Investments",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(10);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_chart),
                  title: Text(
                    "New Investments Type",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTap(11);
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
  void initState() {
    super.initState();
    _loadPhoto();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    const double bottomHeight = 80;

    Widget buildNavButton(IconData icon, int index) {
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
            shape: BoxShape.circle,
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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: theme.primaryColor),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
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
                        child: AccountCard(photoUrl: _photoUrl,),
                      );
                    },
                  );
                },
                icon: CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                      ? NetworkImage(_photoUrl!)
                      : const AssetImage('assets/images/default_avatar.png')
                  as ImageProvider,
                )
              ),
              IconButton(
                onPressed: _toggleHide,
                icon: Icon(
                  _hideSensitive
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _getPage(_currentIndex),
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
                buildNavButton(Icons.dashboard, 0),
                buildNavButton(Icons.qr_code_scanner, 8),
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
                buildNavButton(Icons.bar_chart_sharp, 7),
                buildNavButton(Icons.pie_chart_sharp, 9),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
