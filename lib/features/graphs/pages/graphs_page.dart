import 'package:econance/features/categories/categories.dart';
import 'package:econance/features/graphs/widgets/category_breakdown_card.dart';
import 'package:econance/features/transactions/revenues_expenses.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/features/graphs/widgets/balance_chart_card.dart';

class GraphsPage extends StatefulWidget {
  final String uid;
  const GraphsPage({super.key, required this.uid});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
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
                          Card(
                            color: Colors.white10.withValues(alpha: .04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your balance is R\$${data['balance']}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  BalanceChartCard(),
                                  const SizedBox(height: 30),
                                  Text(
                                    'Want to check on your revenues/expenses?',
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
                                          builder: (context) =>
                                              RevenuesExpensesPage(uid: uid),
                                        );
                                      },
                                      child: Text("Check"),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  CategoryBreakdownChart(type: "expense"),
                                  const SizedBox(height: 20),
                                  CategoryBreakdownChart(type: "revenue"),
                                  const SizedBox(height: 20),
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
                                          builder: (context) =>
                                              CategoriesPage(uid: uid),
                                        );
                                      },
                                      child: Text("Manage"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
