import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cards/home_card.dart';
import '../graphs/widgets/revenue_line_chart.dart';

class HomePage extends StatefulWidget {
  final bool hideSensitive;
  const HomePage({super.key, required this.hideSensitive});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _dataFuture;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final now = DateTime.now();
    final firstDayThisMonth = DateTime(now.year, now.month, 1);
    final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
    final firstDayNextMonth = DateTime(now.year, now.month + 1, 1);

    final revenuesSnapThisMonth = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .where('date', isGreaterThanOrEqualTo: firstDayThisMonth)
        .where('date', isLessThan: firstDayNextMonth)
        .get();
    final revenuesSnapLastMonth = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .where('date', isGreaterThanOrEqualTo: firstDayLastMonth)
        .where('date', isLessThan: firstDayThisMonth)
        .get();

    double totalRevenueThisMonth = revenuesSnapThisMonth.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['value'] as num).toDouble(),
    );
    double totalRevenueLastMonth = revenuesSnapLastMonth.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['value'] as num).toDouble(),
    );
    double revenueChange = totalRevenueLastMonth == 0
        ? 0
        : ((totalRevenueThisMonth - totalRevenueLastMonth) /
                  totalRevenueLastMonth) *
              100;

    final expensesSnapThisMonth = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: firstDayThisMonth)
        .where('date', isLessThan: firstDayNextMonth)
        .get();
    final expensesSnapLastMonth = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: firstDayLastMonth)
        .where('date', isLessThan: firstDayThisMonth)
        .get();

    double totalExpensesThisMonth = expensesSnapThisMonth.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['value'] as num).toDouble(),
    );
    double totalExpensesLastMonth = expensesSnapLastMonth.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc['value'] as num).toDouble(),
    );
    double expensesChange = totalExpensesLastMonth == 0
        ? 0
        : ((totalExpensesThisMonth - totalExpensesLastMonth) /
                  totalExpensesLastMonth) *
              100;

    final investmentsSnapThisMonth = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .where('date', isGreaterThanOrEqualTo: firstDayThisMonth)
        .where('date', isLessThan: firstDayNextMonth)
        .get();
    final investmentsSnapLastMonth = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .where('date', isGreaterThanOrEqualTo: firstDayLastMonth)
        .where('date', isLessThan: firstDayThisMonth)
        .get();

    double totalInvestmentsThisMonth = investmentsSnapThisMonth.docs
        .fold<double>(0, (sum, doc) => sum + (doc['value'] as num).toDouble());
    double totalInvestmentsLastMonth = investmentsSnapLastMonth.docs
        .fold<double>(0, (sum, doc) => sum + (doc['value'] as num).toDouble());
    double investmentsChange = totalInvestmentsLastMonth == 0
        ? 0
        : ((totalInvestmentsThisMonth - totalInvestmentsLastMonth) /
                  totalInvestmentsLastMonth) *
              100;

    final balanceThisMonth = totalRevenueThisMonth - totalExpensesThisMonth;
    final balanceLastMonth = totalRevenueLastMonth - totalExpensesLastMonth;
    double balanceChange = balanceLastMonth == 0
        ? 0
        : ((balanceThisMonth - balanceLastMonth) / balanceLastMonth) * 100;

    return {
      'balance': balanceThisMonth,
      'totalRevenue': totalRevenueThisMonth,
      'totalExpenses': totalExpensesThisMonth,
      'investments': totalInvestmentsThisMonth,
      'balanceChange': balanceChange,
      'revenueChange': revenueChange,
      'expensesChange': expensesChange,
      'investmentsChange': investmentsChange,
    };
  }

  Color _getChangeColor(double change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }
  String formatNumber(double value) {
    if (value >= 1e9) return "${(value / 1e9).toStringAsFixed(1)}B";
    if (value >= 1e6) return "${(value / 1e6).toStringAsFixed(1)}M";
    if (value >= 1e3) return "${(value / 1e3).toStringAsFixed(1)}K";
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome,",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final personalInfo =
                      data['personalInfo'] as Map<String, dynamic>? ?? {};
                  final name = personalInfo['fullName'] ?? 'User';
                  return Text(
                    "$name!",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              FutureBuilder<Map<String, dynamic>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final data = snapshot.data!;
                  final cards = [
                    {
                      'title': 'Total Balance',
                      'value': 'balance',
                      'change': 'balanceChange',
                      'icon': Icons.account_balance_wallet,
                      'iconColor': theme.primaryColor,
                    },
                    {
                      'title': 'Revenue',
                      'value': 'totalRevenue',
                      'change': 'revenueChange',
                      'icon': Icons.attach_money,
                      'iconColor': theme.primaryColor,
                    },
                    {
                      'title': 'Expenses',
                      'value': 'totalExpenses',
                      'change': 'expensesChange',
                      'icon': Icons.remove_circle,
                      'iconColor': Colors.red,
                    },
                    {
                      'title': 'Investments',
                      'value': 'investments',
                      'change': 'investmentsChange',
                      'icon': Icons.show_chart,
                      'iconColor': Colors.purple,
                    },
                  ];
                  return GridView.builder(
                    itemCount: cards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.4,
                        ),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final valueKey = card['value'] as String;
                      final changeKey = card['change'] as String;
                      final double realValue = data[valueKey] as double;
                      final double changeValue = data[changeKey] as double;

                      return DashboardCard(
                        title: card['title'] as String,
                        value: widget.hideSensitive
                            ? "•••••"
                            : formatNumber(realValue),
                        subtitle: widget.hideSensitive
                            ? "••••• VS Last Month"
                            : "${changeValue > 0 ? '+' : ''}${changeValue.toStringAsFixed(1)}% VS Last Month",
                        icon: card['icon'] as IconData?,
                        iconColor: card['iconColor'] as Color?,
                        subtitleColor: _getChangeColor(changeValue),
                        isSelected: selectedIndex == index,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      );

                    },
                  );
                },
              ),
              const SizedBox(height: 30),
              RevenueLineChart(
                selectedCardIndex: selectedIndex,
                hideSensitive: widget.hideSensitive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
