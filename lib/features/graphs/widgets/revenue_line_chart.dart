import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'line_chart_card.dart';

Stream<Map<String, double>> getMonthyRevenues(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('revenues')
      .snapshots()
      .map((snapshot) {
        final Map<String, double> monthyTotals = {};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final ts = data['date'] as Timestamp;
          final date = ts.toDate();

          final monthKey =
              "${date.year}-${date.month.toString().padLeft(2, '0')}";

          monthyTotals[monthKey] =
              (monthyTotals[monthKey] ?? 0) + (data['value'] as num).toDouble();
        }

        return monthyTotals;
      });
}

class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<Map<String, double>>(
      stream: getMonthyRevenues(uid),
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
          title: "Revenues Over Time",
          total: "R\$ $total",
          points: points,
          labels: months,
        );
      },
    );
  }
}
