import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveTransaction({
    required String type,
    required double value,
    String? note,
    String? categoryId,
    DateTime? selectedDate,
    bool isRecurrent = false,
    bool isInvoice = false,
    List<Map<String, dynamic>>? items,
  }) async {
    DateTime? nextDate;
    if (isRecurrent && selectedDate != null) {
      nextDate = _calculateNextDate(selectedDate);
    }

    final data = {
      'type': type,
      'value': value,
      'note': note ?? '',
      'categoryId': categoryId,
      'isRecurrent': isRecurrent,
      'date': selectedDate != null ? Timestamp.fromDate(selectedDate) : null,
      'nextDate': nextDate != null ? Timestamp.fromDate(nextDate) : null,
      'createdAt': FieldValue.serverTimestamp(),
      if (isInvoice && items != null)
        'items': items
            .map((item) => {'name': item['name'], 'value': item['value']})
            .toList(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(type == "expense" ? "expenses" : "revenues")
        .add(data);

  }

  DateTime _calculateNextDate(DateTime date) {
    int year = date.year + (date.month == 12 ? 1 : 0);
    int month = date.month % 12 + 1;
    int day = date.day;

    int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    if (day > lastDayOfMonth) day = lastDayOfMonth;

    return DateTime(year, month, day);
  }

  Future<void> checkAndGenerateRecurringTransactions() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    for (final type in ['expenses', 'revenues']) {
      final snapshot = await userRef
          .collection(type)
          .where('isRecurrent', isEqualTo: true)
          .where('nextDate',
          isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        DateTime nextDate = (data['nextDate'] as Timestamp).toDate();

        while (!nextDate.isAfter(DateTime.now())) {
          await userRef.collection(type).add({
            ...data,
            'date': Timestamp.fromDate(nextDate),
            'nextDate': Timestamp.fromDate(_calculateNextDate(nextDate)),
            'createdAt': FieldValue.serverTimestamp(),
          });

          nextDate = _calculateNextDate(nextDate);
          await doc.reference.update({
            'nextDate': Timestamp.fromDate(nextDate),
          });

          print('✅ Recorrência gerada automaticamente em ${nextDate.toIso8601String()}');
        }
      }
    }
  }
}
