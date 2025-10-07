import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../investments/investments_page.dart';

class InvestmentBreakdownChart extends StatelessWidget {
  final String uid;

  const InvestmentBreakdownChart({super.key, required this.uid});

  Stream<Map<String, double>> _getInvestmentData(String uid) async* {
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .snapshots()
        .map((snapshot) {
      final Map<String, double> typeSums = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String? ?? "Unknown";
        final value = (data['value'] as num?)?.toDouble() ?? 0.0;

        typeSums[type] = (typeSums[type] ?? 0) + value;
      }

      return typeSums;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<Map<String, double>>(
      stream: _getInvestmentData(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text("No investments found"));
        }

        final total = data.values.fold<double>(0, (sum, v) => sum + v);

        final sections = data.entries.map((entry) {
          final percent = (entry.value / total) * 100;
          final color =
          Colors.primaries[entry.key.hashCode % Colors.primaries.length];
          return PieChartSectionData(
            value: entry.value,
            color: color,
            title: "${percent.toStringAsFixed(0)}%",
            radius: 50,
            titleStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList();

        return Card(
          color: Colors.white10.withOpacity(.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Investments by Type",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => InvestmentsPage(uid: uid),
                        );
                      },
                      child: const Text("Manage"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: data.keys.map((type) {
                    final color =
                    Colors.primaries[type.hashCode % Colors.primaries.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: color, size: 10),
                        const SizedBox(width: 4),
                        Text(type, style: theme.textTheme.bodySmall),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
