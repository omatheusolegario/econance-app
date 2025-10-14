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

  const GraphsPage({super.key, required this.uid, required this.hideSensitive});

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  late Future<Map<String, dynamic>> _dataFuture;
  late final uid = widget.uid;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

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
      'hasExpenses': expensesSnap.docs.isNotEmpty,
      'hasRevenue': revenuesSnap.docs.isNotEmpty,
    };
  }

  String formatNumber(double value) {
    if (value >= 1e9) return "${(value / 1e9).toStringAsFixed(1)}B";
    if (value >= 1e6) return "${(value / 1e6).toStringAsFixed(1)}M";
    if (value >= 1e3) return "${(value / 1e3).toStringAsFixed(1)}K";
    return value.toStringAsFixed(1);
  }

  Widget _sensitivePlaceholder(BuildContext context, {String? message}) {
    final theme = Theme.of(context);
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white10.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message ?? 'Sensitive data hidden',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
      ),
    );
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
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
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
                    return Center(
                      child: Text(
                        'Ocorreu um erro ao carregar os dados.\n${snapshot.error}',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma informação disponível no momento.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final balanceData = data['balance'] as double? ?? 0;
                  final balanceString = formatNumber(balanceData);
                  final hasExpenses = data['hasExpenses'] as bool;
                  final hasRevenue = data['hasRevenue'] as bool;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                              if (!widget.hideSensitive && (hasExpenses || hasRevenue))
                                BalanceChartCard(uid: uid, hideSensitive: widget.hideSensitive)
                              else if (!hasExpenses && !hasRevenue)
                                const Text(
                                  'Nenhum dado de balance disponível.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                  onPressed: widget.hideSensitive
                                      ? null
                                      : () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                      ),
                                      builder: (context) => RevenuesExpensesPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Check"),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (widget.hideSensitive)
                                _sensitivePlaceholder(context)
                              else ...[
                                hasExpenses
                                    ? CategoryBreakdownChart(type: "expense", uid: uid)
                                    : const Text('Nenhuma despesa registrada.', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 20),
                                hasRevenue
                                    ? CategoryBreakdownChart(type: "revenue", uid: uid)
                                    : const Text('Nenhuma receita registrada.', style: TextStyle(color: Colors.white70)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manage your categories',
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: widget.hideSensitive
                                      ? null
                                      : () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                      ),
                                      builder: (context) => CategoriesPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Manage"),
                                ),
                              ),
                              if (widget.hideSensitive)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Sensitive data hidden',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      widget.hideSensitive ? _sensitivePlaceholder(context) : InvestmentBreakdownChart(uid: uid),
                      const SizedBox(height: 20),

                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manage your investments',
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: widget.hideSensitive
                                      ? null
                                      : () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                      ),
                                      builder: (_) => InvestmentsPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Manage"),
                                ),
                              ),
                              if (widget.hideSensitive)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Sensitive data hidden',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        color: Colors.white10.withOpacity(.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manage your investments types',
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: widget.hideSensitive
                                      ? null
                                      : () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                      ),
                                      builder: (_) => InvestmentTypesPage(uid: uid),
                                    );
                                  },
                                  child: const Text("Manage"),
                                ),
                              ),
                              if (widget.hideSensitive)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Sensitive data hidden',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
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
