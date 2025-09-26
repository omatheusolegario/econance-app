import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'l10n/app_localizations.dart';

class RevenuesExpensesPage extends StatefulWidget {
  const RevenuesExpensesPage({super.key});

  @override
  State<RevenuesExpensesPage> createState() => _RevenuesExpensesPageState();
}

class _RevenuesExpensesPageState extends State<RevenuesExpensesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Revenues and Expenses")),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Here, you will manage",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "Revenues & Expenses",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, "/add-revenue"),
                    icon: const Icon(Icons.add),
                    label: Text("Add Revenue"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, "/add-expense"),
                    icon: const Icon(Icons.add),
                    label: Text("Add Expense"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDD4B4B)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
