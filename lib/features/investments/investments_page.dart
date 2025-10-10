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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                "Track and manage your investments",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Your Investments",
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: investments == null
                    ? const Center(child: CircularProgressIndicator())
                    : investments!.isEmpty
                    ? Center(
                        child: Text(
                          "No investments yet",
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: investments!.length,
                        itemBuilder: (context, index) {
                          final inv = investments![index];
                          final amount =
                              (inv['value'] as num?)?.toDouble() ?? 0.0;
                          final target =
                              (inv['targetValue'] as num?)?.toDouble() ?? 0.0;
                          final progress = target > 0
                              ? (amount / target).clamp(0.0, 1.0)
                              : 0.0;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        inv['name'] ?? 'Unnamed',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: inv['status'] == 'active'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            inv['status'] == 'active'
                                                ? "Active"
                                                : "Closed",
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "R\$ ${amount.toStringAsFixed(2)} / R\$ ${target.toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: progress,
                                    color: theme.primaryColor,
                                    backgroundColor: theme.dividerColor,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: theme.iconTheme.color,
                                        ),
                                        onPressed: () =>
                                            _openEditInvestment(inv),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: theme.iconTheme.color,
                                        ),
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
    );
  }
}
