import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:econance/theme/responsive_colors.dart';

class LineChartCard extends StatelessWidget {
  final String title;
  final List<FlSpot> points;
  final String total;
  final List<String> labels;
  final bool hideSensitive;
  final String? kind;

  const LineChartCard({
    super.key,
    required this.title,
    this.kind,
    required this.points,
    required this.total,
    required this.labels,
    required this.hideSensitive,
  });

  String formatNumber(double value) {
    if (value >= 1e9) return "${(value / 1e9).toStringAsFixed(1)}B";
    if (value >= 1e6) return "${(value / 1e6).toStringAsFixed(1)}M";
    if (value >= 1e3) return "${(value / 1e3).toStringAsFixed(1)}K";
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

  final String kindLower = (kind ?? title).toLowerCase();
  final Color lineColor = kindLower.contains('expense')
    ? ResponsiveColors.chartExpense(theme)
    : kindLower.contains('revenue')
    ? ResponsiveColors.chartRevenue(theme)
    : kindLower.contains('balance')
    ? ResponsiveColors.chartBalance(theme)
    : ResponsiveColors.chartInvestment(theme);

    final maxY = points.isNotEmpty
        ? points.map((p) => p.y).reduce((a, b) => a > b ? a : b)
        : 0;

    return Card(
  color: ResponsiveColors.whiteOpacity(theme, .04),
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
                    minY: 0,
                    maxY: maxY * 1.1,
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
                          reservedSize: 55,
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max) {
                              return const SizedBox.shrink();
                            }

                            if (hideSensitive) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: ResponsiveColors.greyShade(theme, 400),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: SizedBox(
                                  width: 40,
                                  child: Text(
                                    formatNumber(value),
                                    textAlign: TextAlign.left,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      height: 1.0,
                                    ),
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
                        spots: points,
                        isCurved: true,
                        color: hideSensitive ? ResponsiveColors.greyShade(theme, 400) : lineColor,
                        barWidth: 3,
                        dotData: FlDotData(show: !hideSensitive),
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
