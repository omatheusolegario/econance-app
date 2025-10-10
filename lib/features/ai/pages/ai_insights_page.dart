import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class AiInsightsPage extends StatefulWidget {
  const AiInsightsPage({super.key});

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  String? _insights;
  bool _loading = true;

  Future<void> _fetchInsights() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('aiInsights')
        .doc(todayKey);

    final docSnap = await docRef.get();

    if (docSnap.exists) {
      setState(() {
        _insights = docSnap['text'];
        _loading = false;
      });
      return;
    }

    final categoriesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .get();

    final Map<String, String> categoryMap = {};
    for (var doc in categoriesSnap.docs) {
      final data = doc.data();
      categoryMap[doc.id] = data['name'];
    }

    final revenueSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .orderBy('date', descending: true)
        .limit(50)
        .get();

    final expenseSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .limit(50)
        .get();

    final revenues = revenueSnap.docs.map((doc) {
      final data = doc.data();
      return {
        "type": "revenue",
        "value": data["value"],
        "categoryId": categoryMap[data["categoryId"]] ?? "Unknown",
        "date": (data["date"] as Timestamp?)?.toDate().toIso8601String(),
        "note": data["note"],
      };
    }).toList();

    final expenses = expenseSnap.docs.map((doc) {
      final data = doc.data();
      return {
        "type": "expense",
        "value": data["value"],
        "categoryId": categoryMap[data["categoryId"]] ?? "Unknown",
        "date": (data["date"] as Timestamp?)?.toDate().toIso8601String(),
        "note": data["note"],
      };
    }).toList();

    final transactions = [...revenues, ...expenses];

    final summaryJson = jsonEncode({"transactions": transactions});

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: "AIzaSyB94OyBMfC1GxL6pBZokQohPH8Z0KPSz0c",
    );

    final prompt =
        """
    You are a financial assistant. Analyze this user's financial data:
    $summaryJson
    Write a concise financial insights report with these sections:
    - Balance Overview (compare revenues vs expenses)
    - Spending by Category
    - Recurrent Expenses
    - Suggestions
    Keep it clear, structured and actionable.
    Format it nicely, and put really nice spaces between areas that need(it's a flutter app).
    Currency is R\$ (BRL)
    """;
    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;

    await docRef.set({
      "text": text,
      "generatedAt": FieldValue.serverTimestamp(),
    });

    setState(() {
      _insights = text;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchInsights();
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
              "AI Insights",
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
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: theme.textTheme.bodyMedium,
                        h3: TextStyle(color: theme.primaryColor),
                        blockSpacing: 12,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
