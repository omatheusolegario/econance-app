import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../features/investments/edit_investment_page.dart';

class InvestmentsPage extends StatefulWidget {
  final String uid;
  const InvestmentsPage({super.key, required this.uid});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  late final uid = widget.uid;
  List<Map<String, dynamic>>? investments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .get();

    final list = snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    list.sort((a, b) {
      final ad = (a['date'] as Timestamp?)?.toDate() ?? DateTime.now();
      final bd = (b['date'] as Timestamp?)?.toDate() ?? DateTime.now();
      return bd.compareTo(ad);
    });

    setState(() {
      investments = list;
    });
  }

  void _openEditInvestment(Map<String, dynamic> inv) {
    final date = (inv['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EditInvestmentPage(
          investmentId: inv['id'],
          initialName: inv['name'],
          initialType: inv['type'],
          initialValue: inv['value']?.toString(),
          initialRate: inv['rate']?.toString(),
          initialTargetValue: inv['targetValue']?.toString(),
          initialStatus: inv['status'],
          initialNotes: inv['notes'],
          initialDate: DateFormat('dd/MM/yyyy').format(date),
        ),
      ),
    ).then((_) => _loadInvestments());
  }

  Future<void> _deleteInvestment(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .doc(id)
        .delete();
    _loadInvestments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  Text(
                    "Your Investments",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Track and manage your investments",
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: investments == null
                        ? const Center(child: CircularProgressIndicator())
                        : investments!.isEmpty
                        ? const Center(child: Text("No investments yet"))
                        : ListView.builder(
                      controller: controller,
                      itemCount: investments!.length,
                      itemBuilder: (context, index) {
                        final inv = investments![index];
                        final amount =
                            (inv['value'] as num?)?.toDouble() ?? 0.0;
                        final target =
                            (inv['targetValue'] as num?)?.toDouble() ?? 0.0;
                        final progress =
                        target > 0 ? (amount / target).clamp(0.0, 1.0) : 0.0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      inv['name'] ?? 'Unnamed',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      inv['status'] == 'active'
                                          ? "🟢 Active"
                                          : "🔴 Closed",
                                      style:
                                      const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                    "R\$ ${amount.toStringAsFixed(2)} / R\$ ${target.toStringAsFixed(2)}"),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: progress,
                                  color: theme.primaryColor,
                                  backgroundColor: Colors.grey[300],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.grey),
                                      onPressed: () =>
                                          _openEditInvestment(inv),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.grey),
                                      onPressed: () =>
                                          _deleteInvestment(inv['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
