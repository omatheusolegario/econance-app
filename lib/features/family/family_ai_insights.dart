import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class FamilyAIInsightsPage extends StatefulWidget {
  final String familyId;
  final String role;
  const FamilyAIInsightsPage({required this.familyId, required this.role, super.key});

  @override
  State<FamilyAIInsightsPage> createState() => _FamilyAIInsightsPageState();
}

class _FamilyAIInsightsPageState extends State<FamilyAIInsightsPage> {
  bool _loading = true;
  String? _insights;
  final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyse();
  }

  Future<void> _fetchAndAnalyse({bool forceNew = false}) async {
    setState(() => _loading = true);

    final db = FirebaseFirestore.instance;
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String docId = todayKey;
    if (forceNew) {
      final timestamp = DateFormat('HHmmss').format(DateTime.now());
      docId = '${todayKey}_$timestamp';
    }

    final docRef = db
        .collection('families')
        .doc(widget.familyId)
        .collection('aiInsights')
        .doc(docId);

    if (!forceNew) {
      final docSnap = await docRef.get();
      if (docSnap.exists && widget.role != 'creator' && widget.role != 'admin') {
        setState(() {
          _insights = docSnap['text'];
          _loading = false;
        });
        return;
      } else if (widget.role == 'member') {
        setState(() {
          _insights = "Wait for your admin to generate it first.";
          _loading = false;
        });
        return;
      }
    }

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

    final prompt = """
Family financial summary. For each member provide:
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

    await docRef.set({
      "text": resp.text,
      "generatedAt": FieldValue.serverTimestamp(),
    });

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
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30.0),
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
            if (widget.role == 'creator' || widget.role == 'admin')
              ElevatedButton.icon(
                onPressed: _loading ? null : () => _fetchAndAnalyse(forceNew: true),
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
                  ? const Center(child: CircularProgressIndicator())
                  : _insights == null
                  ? const Text("No insights available")
                  : Markdown(
                data: _insights ?? "",
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme)
                    .copyWith(
                    p: theme.textTheme.bodyMedium,
                    h3: TextStyle(color: theme.primaryColor),
                    blockSpacing: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
