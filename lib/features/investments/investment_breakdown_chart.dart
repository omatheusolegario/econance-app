import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econance/l10n/app_localizations.dart';

class InvestmentBreakdownChart extends StatefulWidget {
  final String uid;

  const InvestmentBreakdownChart({super.key, required this.uid});

  @override
  State<InvestmentBreakdownChart> createState() =>
      _InvestmentBreakdownChartState();
}

class _InvestmentBreakdownChartState extends State<InvestmentBreakdownChart> {
  String chartType = "pie";

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
      stream: _getInvestmentData(widget.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noInvestmentsFound));
        }

        final total = data.values.fold<double>(0, (sum, v) => sum + v);

        final colors = {
          for (var name in data.keys)
            name: Colors.primaries[name.hashCode % Colors.primaries.length],
        };

        Widget buildPieChart() {
          final sections = data.entries.map((entry) {
            final percent = (entry.value / total) * 100;
            return PieChartSectionData(
              value: entry.value,
              color: colors[entry.key],
              title: "${percent.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();

          return PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              borderData: FlBorderData(show: false),
            ),
          );
        }

        Widget buildBarChart() {
          final entries = data.entries.toList();
          final barGroups = List.generate(entries.length, (i) {
            final entry = entries[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: colors[entry.key],
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          });

          return BarChart(
            BarChartData(
              barGroups: barGroups,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final name = entries[value.toInt()].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          name.length > 6 ? '${name.substring(0, 6)}…' : name,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        Widget buildLineChart() {
          final entries = data.entries.toList();

          return LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final name = entries[value.toInt()].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          name.length > 6 ? '${name.substring(0, 6)}…' : name,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                  dotData: FlDotData(show: true),
                  spots: List.generate(entries.length, (i) {
                    return FlSpot(i.toDouble(), entries[i].value);
                  }),
                ),
              ],
            ),
          );
        }

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
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.investmentsByType,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ToggleButtons(
                          borderRadius: BorderRadius.circular(12),
                          borderWidth: 0,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          selectedColor: Theme.of(context).hintColor,
                          fillColor: Theme.of(context).primaryColor,
                          splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          isSelected: [
                            chartType == "pie",
                            chartType == "bar",
                            chartType == "line",
                          ],
                          onPressed: (index) {
                            setState(() {
                              chartType = ["pie", "bar", "line"][index];
                            });
                          },
                          constraints: const BoxConstraints(
                            minHeight: 36,
                            minWidth: 40,
                          ),
                          children: const [
                            Icon(Icons.pie_chart, size: 18),
                            Icon(Icons.bar_chart, size: 18),
                            Icon(Icons.show_chart, size: 18),
                          ],
                        )
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: chartType == "pie"
                        ? buildPieChart()
                        : chartType == "bar"
                        ? buildBarChart()
                        : buildLineChart(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: data.keys.map((type) {
                    final color = colors[type]!;
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
