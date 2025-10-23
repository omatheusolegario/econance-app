import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';

class AiInsightsPage extends StatefulWidget {
  const AiInsightsPage({super.key});

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  String? _insights;
  bool _loading = true;

  Future<void> _fetchInsights({bool forceNew = false}) async {
    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String docId = todayKey;
    if (forceNew) {
      final timestamp = DateFormat('HHmmss').format(DateTime.now());
      docId = '${todayKey}_$timestamp';
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('aiInsights')
        .doc(docId);

    if (!forceNew) {
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        setState(() {
          _insights = docSnap['text'];
          _loading = false;
        });
        return;
      }
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

    final investmentSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final investments = investmentSnap.docs.map((doc) {
      final data = doc.data();
      return {
        "type": "investment",
        "name": data["name"],
        "status": data["status"],
        "investmentType": data["type"],
        "value": data["value"],
        "targetValue": data["targetValue"],
        "rate": data["rate"],
        "notes": data["notes"],
        "createdAt": (data["createdAt"] as Timestamp?)
            ?.toDate()
            .toIso8601String(),
        "updatedAt": (data["updatedAt"] as Timestamp?)
            ?.toDate()
            .toIso8601String(),
        "date": (data["date"] as Timestamp?)?.toDate().toIso8601String(),
      };
    }).toList();

    final transactions = [...revenues, ...expenses];
    final summaryJson = jsonEncode({"transactions": transactions, "investments": investments});

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );

    final prompt = """
You are a financial assistant. Analyze this user's financial data:
$summaryJson
Write a concise financial insights report with these sections:
- Balance Overview (compare revenues vs expenses)
- Spending by Category
- Recurrent Expenses
- Suggestions
- Investment Overview (analyze user's investments, showing total value, goals, rate, and suggestions)
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

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: ListView(
        children: [
          Container(
            height: 28,
            width: 200,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 10),
          ),
          const SizedBox(height: 10),
          _buildShimmerSection(),
          const SizedBox(height: 20),
          _buildShimmerSection(),
          const SizedBox(height: 20),
          _buildShimmerSection(),
        ],
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          width: 120,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),
        ...List.generate(
          4,
              (i) => Container(
            height: 12,
            width: i == 3 ? 180 : double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
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
            ElevatedButton.icon(
              onPressed: _loading ? null : () => _fetchInsights(forceNew: true),
              icon: _loading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.refresh),
              label: const Text("Gerar Novamente   "),
            ),
            const SizedBox(height: 7),
            Expanded(
              child: _loading
                  ? _buildShimmerLoading(context)
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
