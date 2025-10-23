import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceChartCard extends StatelessWidget {
  final String uid;
  final bool hideSensitive;

  const BalanceChartCard({
    super.key,
    required this.uid,
    required this.hideSensitive,
  });

  Stream<Map<String, Map<String, double>>> _getMonthlyData(String uid) {
    final revenuesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .snapshots();

    final expensesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .snapshots();

    final investmentsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .snapshots();

    return revenuesStream.asyncMap((revenuesSnapshot) async {
      final expensesSnapshot = await expensesStream.first;
      final investmentsSnapshot = await investmentsStream.first;

      final Map<String, Map<String, double>> monthlyData = {};

      void addData(QuerySnapshot snapshot, String keyName) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data['date'] as Timestamp;
          final date = ts.toDate();
          final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
          monthlyData[key] ??= {"revenue": 0, "expense": 0, "investment": 0};
          monthlyData[key]![keyName] =
              (monthlyData[key]![keyName] ?? 0) + (data['value'] as num).toDouble();
        }
      }

      addData(revenuesSnapshot, "revenue");
      addData(expensesSnapshot, "expense");
      addData(investmentsSnapshot, "investment");

      return monthlyData;
    });
  }

  String formatNumber(double value) {
    if (value >= 1e12) return "${(value / 1e12).toStringAsFixed(1)}T";
    if (value >= 1e9) return "${(value / 1e9).toStringAsFixed(1)}B";
    if (value >= 1e6) return "${(value / 1e6).toStringAsFixed(1)}M";
    if (value >= 1e3) return "${(value / 1e3).toStringAsFixed(1)}K";
    if (value <= -1e12) return "-${(-value / 1e12).toStringAsFixed(1)}T";
    if (value <= -1e9) return "-${(-value / 1e9).toStringAsFixed(1)}B";
    if (value <= -1e6) return "-${(-value / 1e6).toStringAsFixed(1)}M";
    if (value <= -1e3) return "-${(-value / 1e3).toStringAsFixed(1)}K";
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<Map<String, Map<String, double>>>(
      stream: _getMonthlyData(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final months = data.keys.toList()..sort();

        final revenuePoints = <FlSpot>[];
        final expensePoints = <FlSpot>[];
        final balancePoints = <FlSpot>[];
        final investmentPoints = <FlSpot>[];
        double cumulativeBalance = 0;

        for (int i = 0; i < months.length; i++) {
          final revenue = data[months[i]]?["revenue"] ?? 0;
          final expense = data[months[i]]?["expense"] ?? 0;
          final investment = data[months[i]]?["investment"] ?? 0;

          cumulativeBalance += (revenue - expense);

          revenuePoints.add(FlSpot(i.toDouble(), revenue));
          expensePoints.add(FlSpot(i.toDouble(), expense));
          balancePoints.add(FlSpot(i.toDouble(), cumulativeBalance));
          investmentPoints.add(FlSpot(i.toDouble(), investment));
        }

        final maxOther = [
          ...revenuePoints.map((e) => e.y),
          ...expensePoints.map((e) => e.y),
          ...investmentPoints.map((e) => e.y),
        ].reduce((a, b) => a > b ? a : b);

        final normalizedBalancePoints = balancePoints.map((e) {
          double y = e.y;
          if (maxOther > 0) {
            if (y > maxOther * 10) y = maxOther * 10;
            if (y < -maxOther * 10) y = -maxOther * 10;
          }
          return FlSpot(e.x, y);
        }).toList();

        final minY = [
          ...revenuePoints.map((e) => e.y),
          ...expensePoints.map((e) => e.y),
          ...investmentPoints.map((e) => e.y),
          ...normalizedBalancePoints.map((e) => e.y),
        ].reduce((a, b) => a < b ? a : b);

        final maxY = [
          ...revenuePoints.map((e) => e.y),
          ...expensePoints.map((e) => e.y),
          ...investmentPoints.map((e) => e.y),
          ...normalizedBalancePoints.map((e) => e.y),
        ].reduce((a, b) => a > b ? a : b);

        return Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: LineChart(
                      LineChartData(
                        minY: minY * 1.1,
                        maxY: maxY * 1.1,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 28,
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= 0 && index < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      months[index],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 80,
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value == meta.max) return const SizedBox.shrink();
                                if (hideSensitive) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      formatNumber(value),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        height: 1.0,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: revenuePoints,
                            isCurved: true,
                            color: hideSensitive ? Colors.grey[400] : Colors.green,
                            barWidth: 3,
                            dotData: FlDotData(show: !hideSensitive),
                          ),
                          LineChartBarData(
                            spots: expensePoints,
                            isCurved: true,
                            color: hideSensitive ? Colors.grey[400] : Colors.red,
                            barWidth: 3,
                            dotData: FlDotData(show: !hideSensitive),
                          ),
                          LineChartBarData(
                            spots: normalizedBalancePoints,
                            isCurved: true,
                            color: hideSensitive ? Colors.grey[400] : Colors.blueAccent,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: !hideSensitive),
                          ),
                          LineChartBarData(
                            spots: investmentPoints,
                            isCurved: true,
                            color: hideSensitive ? Colors.grey[400] : Colors.purple,
                            barWidth: 2,
                            dotData: FlDotData(show: !hideSensitive),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: hideSensitive ? Colors.grey[400] : Colors.green, size: 10),
                        const SizedBox(width: 4),
                        Text("Revenues", style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Icon(Icons.circle, color: hideSensitive ? Colors.grey[400] : Colors.red, size: 10),
                        const SizedBox(width: 4),
                        Text("Expenses", style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.circle, color: hideSensitive ? Colors.grey[400] : Colors.blueAccent, size: 10),
                        const SizedBox(width: 4),
                        Text("Balance", style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Icon(Icons.circle, color: hideSensitive ? Colors.grey[400] : Colors.purple, size: 10),
                        const SizedBox(width: 4),
                        Text("Investments", style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
