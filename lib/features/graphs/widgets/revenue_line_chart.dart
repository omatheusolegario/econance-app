import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'line_chart_card.dart';

Stream<Map<String, double>> getMonthlyData(String uid, String collection) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection(collection)
      .snapshots()
      .map((snapshot) {
    final Map<String, double> monthlyTotals = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final ts = data['date'] as Timestamp;
      final date = ts.toDate();
      final monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0) + (data['value'] as num).toDouble();
    }
    return monthlyTotals;
  });
}

Stream<Map<String, double>> getMonthlyBalance(String uid) async* {
  final revenueStream = getMonthlyData(uid, 'revenues');
  final expenseStream = getMonthlyData(uid, 'expenses');

  await for (final revenues in revenueStream) {
    final expensesSnapshot = await expenseStream.first;
    final allMonths = {...revenues.keys, ...expensesSnapshot.keys};

    final Map<String, double> balances = {};
    for (final month in allMonths) {
      final revenue = revenues[month] ?? 0;
      final expense = expensesSnapshot[month] ?? 0;
      balances[month] = revenue - expense;
    }

    yield balances;
  }
}

class RevenueLineChart extends StatelessWidget {
  final int selectedCardIndex;
  final bool hideSensitive;

  const RevenueLineChart({
    super.key,
    required this.selectedCardIndex,
    required this.hideSensitive,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final Stream<Map<String, double>> stream = switch (selectedCardIndex) {
      0 => getMonthlyBalance(uid),
      1 => getMonthlyData(uid, 'revenues'),
      2 => getMonthlyData(uid, 'expenses'),
      3 => getMonthlyData(uid, 'investments'),
      _ => getMonthlyData(uid, 'revenues'),
    };

    final titles = [
      'Balance Over Time',
      'Revenue Over Time',
      'Expenses Over Time',
      'Investments Over Time'
    ];
    final title = titles[selectedCardIndex];

    return StreamBuilder<Map<String, double>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final monthlyTotals = snapshot.data!;
        final months = monthlyTotals.keys.toList()..sort();

        final points = <FlSpot>[];
        for (int i = 0; i < months.length; i++) {
          points.add(FlSpot(i.toDouble(), monthlyTotals[months[i]]!));
        }

        final total = monthlyTotals.values
            .fold<double>(0, (a, b) => a + b)
            .toStringAsFixed(2);

        return LineChartCard(
          title: title,
          total: hideSensitive ? "•••••" : "R\$ $total",
          points: points,
          labels: months,
        );
      },
    );
  }
}
