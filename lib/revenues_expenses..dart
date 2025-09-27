import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';

class RevenuesExpensesPage extends StatefulWidget {
  const RevenuesExpensesPage({super.key});

  @override
  State<RevenuesExpensesPage> createState() => _RevenuesExpensesPageState();
}

class _RevenuesExpensesPageState extends State<RevenuesExpensesPage> with RouteAware{
  final uid = FirebaseAuth.instance.currentUser!.uid;

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

    print("Expenses count: ${expensesSnap.docs.length}");
    print("Revenues count: ${revenuesSnap.docs.length}");

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
    print("Merged count: ${all.length}");
    return all;
  }

  final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
  List<Map<String, dynamic>>? transactions;


  @override void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadTransactions();
  }

  @override void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override void didPopNext() {
   _loadTransactions();
  }

  Future<void> _loadTransactions() async{
    final data = await _fetchTransactions();
    setState(() {
      transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30.0),
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
                    onPressed: () =>
                        Navigator.pushNamed(context, "/add-revenue"),
                    icon: const Icon(Icons.add),
                    label: Text("Add Revenue"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, "/add-expense"),
                    icon: const Icon(Icons.add),
                    label: Text("Add Expense"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD4B4B),
                    ),
                  ),
                ),
              ],
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
                    return const Center(child: Text("No data yet"));
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
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                          title: Text(
                            "${isExpense ? "-" : "+"} R\$ ${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          subtitle: Text(
                            "${date.day}/${date.month}/${date.year}",
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection(
                                    isExpense ? 'expenses' : 'revenues',
                                  )
                                  .doc(t['id'])
                                  .delete();
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete, color: Colors.grey),
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
