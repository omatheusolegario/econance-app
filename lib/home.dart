import 'package:flutter/material.dart';
import 'theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String,dynamic>> _dataFuture;

  @override
  void initState(){
    super.initState();
    _dataFuture = _fetchData();
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> _fetchData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final personalInfo = userDoc['personalInfo'] as Map<String, dynamic>? ?? {};
    final name = personalInfo['fullName'] ?? 'User';

    final expensesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .get();
    final totalExpenses = expensesSnap.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['value'] as num).toDouble(),
    );

    final revenuesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .get();
    final totalRevenue = revenuesSnap.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['value'] as num).toDouble(),
    );

    return {
      'name': name,
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'balance': totalRevenue - totalExpenses,
    };
  }

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

    return GestureDetector(
      onTap: _closeIfExpanded,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back,",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
                ),
                Container(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _dataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final data = snapshot.data!;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['name']}!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.4,
                              shrinkWrap: true,
                              children: [
                                DashboardCard(
                                  title: "Total Balance",
                                  value: 'R\$${data['balance']}',
                                  subtitle: "+17% VS Last Month",
                                  icon: Icons.account_balance_wallet,
                                  iconColor: Colors.green,
                                ),
                                DashboardCard(
                                  title: "Revenue",
                                  value: 'R\$${data['totalRevenue']}',
                                  subtitle: "Same revenue as last month",
                                  icon: Icons.attach_money,
                                  iconColor: Colors.green,
                                ),
                                DashboardCard(
                                  title: "Expenses",
                                  value: 'R\$${data['totalExpenses']}',
                                  subtitle: "-8% VS Last Month",
                                  icon: Icons.remove_circle,
                                  iconColor: Colors.red,
                                ),
                                DashboardCard(
                                  title: "Investments",
                                  value: 'R\$${data['balance']}',
                                  subtitle: "+29% VS Last Month",
                                  backgroundColor: Colors.green.shade100,
                                  icon: Icons.show_chart,
                                  iconColor: Colors.green.shade900,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
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
                                    () => Navigator.pushNamed(
                                      context,
                                      "/revenues-expenses",
                                    ),
                                  ),
                                  _buildMenuItem(
                                    Icons.dashboard,
                                    "Dashboard",
                                    () => Navigator.pushNamed(
                                      context,
                                      "/revenues-expenses",
                                    ),
                                  ),
                                  _buildMenuItem(
                                    Icons.qr_code_scanner,
                                    "Scan Bill",
                                    () => Navigator.pushNamed(
                                      context,
                                      "/revenues-expenses",
                                    ),
                                  ),
                                  _buildMenuItem(
                                    Icons.sell,
                                    "Categories",
                                    () => Navigator.pushNamed(
                                      context,
                                      "/add-category",
                                    ),
                                  ),
                                  _buildMenuItem(
                                    Icons.family_restroom,
                                    "Family",
                                    () => Navigator.pushNamed(
                                      context,
                                      "/add-category",
                                    ),
                                  ),
                                  _buildMenuItem(
                                    Icons.settings,
                                    "Settings",
                                    () => Navigator.pushNamed(
                                      context,
                                      "/add-category",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, "/add-category"),
                                child: Icon(
                                  Icons.dashboard,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, "/add-category"),
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),

                              InkWell(
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
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, "/add-category"),
                                child: Icon(
                                  Icons.bar_chart_sharp,
                                  size: 36,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),
                              SizedBox(
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(context, "/add-category"),
                                  child: Icon(
                                    Icons.pie_chart_sharp,
                                    color: theme.scaffoldBackgroundColor,
                                  ),
                                ),
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
