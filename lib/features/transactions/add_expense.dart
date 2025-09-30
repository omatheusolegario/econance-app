import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../categories/category_picker.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String? selectedCategoryId;
  String? selectedCategoryName;

  Future<void> _pickCategory(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPickerPage(type: "expense")));

    if (result != null){
      setState(() {
        selectedCategoryId = result;
        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('categories').doc(result).get().then((doc){
          selectedCategoryName = doc['name'];
          setState(() {

          });
        });
      });
    }
  }

  final _value = TextEditingController();
  final _date = TextEditingController();
  final _note = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate() async{
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _date.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> addExpense() async{
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).collection('expenses').add({
      'type': 'expense',
      'value': double.tryParse(_value.text.trim()) ?? 0,
      'categoryId': selectedCategoryId,
      'note': _note.text.trim(),
      'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      'createdAt': FieldValue.serverTimestamp()
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Expense added")));
    _value.clear();
    _note.clear();
    _date.clear();
    selectedCategoryId = null;
    selectedCategoryName = null;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add new Expense",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Value",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              TextField(
                style:  theme.textTheme.bodyMedium,
                controller: _value,
                decoration: InputDecoration(hintText: "Ex: 409"),
              ),
              const SizedBox(height: 15),
              Text(
                "Note",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              TextField(
                style:  theme.textTheme.bodyMedium,
                controller: _note,
                decoration: InputDecoration(hintText: "Add any commentary you want"),
              ),
              const SizedBox(height: 15,),
              Text(
                "Category",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 7,),
              Container(
                decoration: BoxDecoration(
                  border: theme.inputDecorationTheme.enabledBorder?.borderSide != null
                      ? Border.all (
                    color: theme.inputDecorationTheme.enabledBorder!.borderSide.color,
                    width: theme.inputDecorationTheme.enabledBorder!.borderSide.width,
                  )
                      :Border.all(color: Colors.grey, width: 1),
                  borderRadius: (theme.inputDecorationTheme.enabledBorder as OutlineInputBorder?)?.borderRadius ?? BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(selectedCategoryName ?? "Select Category", style: theme.textTheme.bodyMedium,),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickCategory(context),
                ),
              ),
              const SizedBox(height: 15,),
              Text(
                "Date",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              TextField(
                style:  theme.textTheme.bodyMedium,
                controller: _date,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  hintText: 'Select a date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addExpense,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
