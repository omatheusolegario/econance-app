import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:econance/theme/responsive_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_transaction.dart';

class RevenuesExpensesPage extends StatefulWidget {
  final String uid;
  const RevenuesExpensesPage({super.key, required this.uid});

  @override
  State<RevenuesExpensesPage> createState() => _RevenuesExpensesPageState();
}

class _RevenuesExpensesPageState extends State<RevenuesExpensesPage> with RouteAware {
  late final uid = widget.uid;

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final expensesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .get();

    final revenuesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .get();

    final expenses = expensesSnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['kind'] = 'expense';
      return data;
    }).toList();

    final revenues = revenuesSnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['kind'] = 'revenue';
      return data;
    }).toList();

    final all = [...expenses, ...revenues];
    all.sort((a, b) {
      final ad = (a['date'] as Timestamp).toDate();
      final bd = (b['date'] as Timestamp).toDate();
      return bd.compareTo(ad);
    });

    return all;
  }

  final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
  List<Map<String, dynamic>>? transactions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadTransactions();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await _fetchTransactions();
    setState(() {
      transactions = data;
    });
  }

  void _openEditModal(Map<String, dynamic> t, double amount, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EditTransactionPage(
          uid: uid,
          type: t['kind'],
          transactionId: t['id'],
          initialValue: amount.toString(),
          initialDate: DateFormat('dd/MM/yyyy').format(date),
          initialCategoryId: t['categoryId'],
          initialNote: t['note'],
          initialItems: t['items'] != null
              ? List<Map<String, dynamic>>.from(t['items'])
              : null,
        ),
      ),
    ).then((_) => _loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30.0),
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
                      color: ResponsiveColors.greyShade(theme, 400),
                      borderRadius: BorderRadius.circular(2)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              AppLocalizations.of(context)!.manageTransactionsIntro,
              style: theme.textTheme.bodyMedium?.copyWith(color: ResponsiveColors.whiteOpacity(theme, 0.6)),
            ),
            const SizedBox(height: 7),
            Text(
              AppLocalizations.of(context)!.revenuesExpensesTitle,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(AppLocalizations.of(context)!.noDataYet));
                  }

                  final transactions = snapshot.data!;

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      final isExpense = t['kind'] == 'expense';
                      final amount = (t['value'] as num).toDouble();
                      final date = (t['date'] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            isExpense ? Icons.remove_circle : Icons.add_circle,
                            color: isExpense ? ResponsiveColors.error(theme) : ResponsiveColors.success(theme),
                          ),
                          title: Text(
                            "${isExpense ? "-" : "+"} R\$ ${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isExpense ? ResponsiveColors.error(theme) : ResponsiveColors.success(theme),
                            ),
                          ),
                          subtitle: Text("${date.day}/${date.month}/${date.year}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: ResponsiveColors.hint(theme)),
                                onPressed: () => _openEditModal(t, amount, date),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: ResponsiveColors.hint(theme)),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection(isExpense ? 'expenses' : 'revenues')
                                      .doc(t['id'])
                                      .delete();
                                  _loadTransactions();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
