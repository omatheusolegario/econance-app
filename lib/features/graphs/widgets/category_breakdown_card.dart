import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final String type;

  const CategoryBreakdownChart({super.key, required this.type});

  Stream<Map<String, double>> _getCategoryData(String uid) async* {
    final categoriesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .where('type', isEqualTo: type)
        .get();

    final categories = {
      for (var doc in categoriesSnapshot.docs) doc.id: doc['name'] as String,
    };

    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(type == "expense" ? "expenses" : "revenues")
        .snapshots()
        .map((snapshot) {
          final Map<String, double> categorySums = {
            for (var name in categories.values) name: 0.0,
          };

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final categoryId =
                data[type == "expense" ? 'categoryId' : 'source'] as String?;
            final value = (data['value'] as num).toDouble();

            if (categoryId != null && categories.containsKey(categoryId)) {
              final categoryName = categories[categoryId]!;
              categorySums[categoryName] =
                  (categorySums[categoryName] ?? 0) + value;
            }
          }
          return categorySums;
        });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return StreamBuilder<Map<String, double>>(
      stream: _getCategoryData(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text("No categories found"));
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
          color: Colors.white10.withValues(alpha: .009),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == "expense"
                      ? "Expenses by Category"
                      : "Revenues by Category",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
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
                  children: data.keys.map((category) {
                    final color = Colors
                        .primaries[category.hashCode % Colors.primaries.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: color, size: 10),
                        const SizedBox(width: 4),
                        Text(category, style: theme.textTheme.bodySmall),
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
