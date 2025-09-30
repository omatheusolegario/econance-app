import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BalanceChartCard extends StatelessWidget {

  Stream<Map<String, Map<String,double>>> _getMonthlyData(String uid){
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

    return revenuesStream.asyncMap((revenuesSnapshot) async {
      final expensesSnapshot = await expensesStream.first;

      final Map<String, Map<String, double>> monthlyData = {};

      for (final doc in revenuesSnapshot.docs) {
        final data = doc.data();
        final ts = data['date'] as Timestamp;
        final date = ts.toDate();

        final key =
            "${date.year}-${date.month.toString().padLeft(2, '0')}";

        monthlyData[key] ??= {"revenue": 0, "expense": 0};
        monthlyData[key]!["revenue"] = (monthlyData[key]!["revenue"] ?? 0) + (data['value'] as  num).toDouble();
      }
      for (final doc in expensesSnapshot.docs) {
        final data = doc.data();
        final ts = data['date'] as Timestamp;
        final date = ts.toDate();

        final key =
            "${date.year}-${date.month.toString().padLeft(2, '0')}";

        monthlyData[key] ??= {"revenue": 0, "expense": 0};
        monthlyData[key]!["expense"] = (monthlyData[key]!["expense"] ?? 0) + (data['value'] as  num).toDouble();
      }

      return monthlyData;
    });

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

  return StreamBuilder<Map<String, Map<String, double>>>(stream: _getMonthlyData(uid), builder: (context, snapshot){
    if (!snapshot.hasData){
      return const Center(child: CircularProgressIndicator(),);
    }
    final data = snapshot.data!;
    final months = data.keys.toList()..sort();

    final revenuePoints = <FlSpot>[];
    final expensePoints = <FlSpot>[];
    final balancePoints = <FlSpot>[];
    double cumulativeBalance = 0;

    for(int i = 0; i< months.length; i++){
      final revenue = data[months[i]]?["revenue"]?? 0;
      final expense = data[months[i]]?["expense"]?? 0;

      cumulativeBalance += (revenue - expense);

      revenuePoints.add(FlSpot(i.toDouble(), revenue));
      expensePoints.add(FlSpot(i.toDouble(), expense));
      balancePoints.add(FlSpot(i.toDouble(), cumulativeBalance));
    }

    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
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
                                padding: EdgeInsets.only(top: 15),
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 60,
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: revenuePoints,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: expensePoints,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: balancePoints,
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children:[
                Icon(Icons.circle, color: Colors.green, size: 10),
                SizedBox(width: 4),
                Text("Revenues",style: theme.textTheme.bodySmall),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Colors.red, size: 10),
                SizedBox(width: 4),
                Text("Expenses",style: theme.textTheme.bodySmall),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Colors.blueAccent, size: 10),
                SizedBox(width: 4),
                Text("Balance",style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );

  });





  }
}
