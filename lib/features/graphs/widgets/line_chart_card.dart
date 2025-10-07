import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartCard extends StatelessWidget {
  final String title;
  final List<FlSpot> points;
  final String total;
  final List<String> labels;

  const LineChartCard({
    super.key,
    required this.title,
    required this.points,
    required this.total,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color lineColor = title.toLowerCase().contains('expense')
        ? Colors.red
        : title.toLowerCase().contains('revenue')
        ? Colors.green
        : title.toLowerCase().contains('balance')
        ? Colors.blueAccent
        : title.toLowerCase().contains('investment')
        ? Colors.purple
        : theme.primaryColor;

    return Card(
      color: Colors.white10.withValues(alpha: .04),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              total,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 24,
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            int index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  labels[index],
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
                          reservedSize: 60,
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
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
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: lineColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
