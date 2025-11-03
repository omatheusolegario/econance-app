import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';

class FamilyAIInsightsPage extends StatefulWidget {
  final String familyId;
  final String role;
  const FamilyAIInsightsPage({
    required this.familyId,
    required this.role,
    super.key,
  });

  @override
  State<FamilyAIInsightsPage> createState() => _FamilyAIInsightsPageState();
}

class _FamilyAIInsightsPageState extends State<FamilyAIInsightsPage> {
  bool _loading = true;
  String? _insights;
  int _currentPhraseIndex = 0;

  final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  final List<String> _phrases = [
    "Analisando finanças da família...",
    "Gerando relatório familiar inteligente...",
    "Comparando rendas e despesas...",
    "Avaliando investimentos de todos...",
    "Preparando insights personalizados da família..."
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyse();

    Future.doWhile(() async {
      if (!_loading) return false;
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && _loading) {
        setState(() {
          _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
        });
      }
      return _loading;
    });
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
          _insights = "Aguarde o administrador gerar os insights primeiro.";
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

      final categoriesSnap =
      await db.collection('users').doc(memberUid).collection('categories').get();
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
      final investmentSnap = await db
          .collection('users')
          .doc(memberUid)
          .collection('investments')
          .orderBy('createdAt', descending: true)
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
        'investments': investmentSnap.docs.map((doc) {
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
            "createdAt":
            (data["createdAt"] as Timestamp?)?.toDate().toIso8601String(),
            "updatedAt":
            (data["updatedAt"] as Timestamp?)?.toDate().toIso8601String(),
            "date": (data["date"] as Timestamp?)?.toDate().toIso8601String(),
          };
        }).toList(),
      };
    }

    final prompt = """
Family financial summary. For each member provide:
- short balance overview,
- top 3 categories for spending,
- any recurring items noticed,
- short investments overview,
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

  Widget _buildShimmerLoading(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade500,
        child: Text(
          _phrases[_currentPhraseIndex],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Family AI Insights",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.role == 'creator' || widget.role == 'admin')
                  IconButton(
                    onPressed:
                    _loading ? null : () => _fetchAndAnalyse(forceNew: true),
                    icon: _loading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Icon(Icons.refresh, color: theme.primaryColor),
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
