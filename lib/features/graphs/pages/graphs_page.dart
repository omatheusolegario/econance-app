import 'package:econance/features/categories/categories.dart';
import 'package:econance/features/graphs/widgets/category_breakdown_card.dart';
import 'package:econance/features/transactions/revenues_expenses.dart';
import 'package:econance/features/graphs/widgets/balance_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../investments/investment_breakdown_chart.dart';
import '../../investments/investments_page.dart';
import '../../investments_types/investment_type.dart';

class GraphsPage extends StatefulWidget {
  final String uid;
  final bool hideSensitive;
  const GraphsPage({super.key, required this.uid,  required this.hideSensitive});

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  late final uid = widget.uid;

  Future<Map<String, dynamic>> _fetchData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final personalInfo = userDoc['personalInfo'] as Map<String, dynamic>? ?? {};
    final name = personalInfo['fullName'] ?? 'User';
    final expensesSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('expenses').get();
    final totalExpenses = expensesSnap.docs.fold<double>(0, (sum, doc) => sum + (doc['value'] as num).toDouble());
    final revenuesSnap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('revenues').get();
    final totalRevenue = revenuesSnap.docs.fold<double>(0, (sum, doc) => sum + (doc['value'] as num).toDouble());
    return {
      'name': name,
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'balance': totalRevenue - totalExpenses,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Here you'll manage",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
              Text(
                "Finances",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
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
                  final balanceData = data['balance'] as double;
                  final balanceString = balanceData.toStringAsFixed(2);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hideSensitive
                                    ? 'The balance is R\$•••••'
                                    : 'The balance is R\$${balanceString}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              BalanceChartCard(uid: uid, hideSensitive: widget.hideSensitive),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Want to check on revenues/expenses?',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25),
                                        ),
                                      ),
                                      builder: (context) => RevenuesExpensesPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Check"),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CategoryBreakdownChart(type: "expense", uid: uid),
                              const SizedBox(height: 20),
                              CategoryBreakdownChart(type: "revenue", uid: uid),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InvestmentBreakdownChart(uid: uid),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage your categories',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25),
                                        ),
                                      ),
                                      builder: (context) => CategoriesPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Manage"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InvestmentBreakdownChart(uid: uid),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage your investments',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25),
                                        ),
                                      ),
                                      builder: (_) => InvestmentsPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Manage"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage your investments types',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25),
                                        ),
                                      ),
                                      builder: (_) => InvestmentTypesPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Manage"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
