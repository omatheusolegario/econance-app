import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FamilyAIInsightsPage extends StatefulWidget {
  final String familyId;
  const FamilyAIInsightsPage({required this.familyId, super.key});

  @override
  State<FamilyAIInsightsPage> createState() => _FamilyAIInsightsPageState();
}

class _FamilyAIInsightsPageState extends State<FamilyAIInsightsPage> {
  bool _loading = true;
  String? _insights;
  final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: "AIzaSyB94OyBMfC1GxL6pBZokQohPH8Z0KPSz0c",
  );

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyse();
  }

  Future<void> _fetchAndAnalyse() async {
    final db = FirebaseFirestore.instance;
    final membersSnap = await db
        .collection('families')
        .doc(widget.familyId)
        .collection('members')
        .get();
    final Map<String, dynamic> summary = {};

    for (final m in membersSnap.docs) {
      final memberUid = m.id;

      final categoriesSnap = await db
          .collection('users')
          .doc(memberUid)
          .collection('categories')
          .get();
      final Map<String, String> categoryMap = {};
      for (var doc in categoriesSnap.docs) {
        final data = doc.data();
        categoryMap[doc.id] = data['name'];
      }
      final revenuesSnap = await db
          .collection('users')
          .doc(memberUid)
          .collection('revenues')
          .orderBy('date', descending: true)
          .limit(50)
          .get();
      final expensesSnap = await db
          .collection('users')
          .doc(memberUid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      summary[memberUid] = {
        'displayName': m['displayName'] ?? '',
        'revenues': revenuesSnap.docs.map((doc) {
          final data = doc.data();
          return {
            "type": "revenue",
            "value": data["value"],
            "categoryId": categoryMap[data["categoryId"]] ?? "Unknown",
            "isRecurrent": data["isRecurrent"],
            "date": (data["date"] as Timestamp?)?.toDate().toIso8601String(),
            "note": data["note"],
          };
        }).toList(),
        'expenses': expensesSnap.docs.map((doc) {
          final data = doc.data();
          return {
            "type": "expense",
            "value": data["value"],
            "categoryId": categoryMap[data["categoryId"]] ?? "Unknown",
            "isRecurrent": data["isRecurrent"],
            "date": (data["date"] as Timestamp?)?.toDate().toIso8601String(),
            "note": data["note"],
          };
        }).toList(),
      };
    }

    final prompt =
        """
        Family financial summary (compact JSON). For each member provide:
        - short balance overview,
        - top 3 categories for spending,
        - any recurring items noticed,
        Then provide a short family-level summary and 3 actionable suggestions
       Data:
       ${jsonEncode(summary)}
       Keep it clear, structured and actionable.
       Format it nicely, and put really nice spaces between areas that need (it's a flutter app).
       Currency is R\$ (BRL)
      """;

    final resp = await _model.generateContent([Content.text(prompt)]);
    setState(() {
      _insights = resp.text;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Here you'll get,",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
            Text(
              "Family AI Insights",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _insights == null
                  ? const Text("No insights available")
                  : Markdown(
                data: _insights ?? "",
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  theme,
                ).copyWith(p: theme.textTheme.bodyMedium, h3:TextStyle(color: theme.primaryColor), blockSpacing: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
