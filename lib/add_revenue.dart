import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'category_picker.dart';

class AddRevenuePage extends StatefulWidget {
  const AddRevenuePage({super.key});

  @override
  State<AddRevenuePage> createState() => _AddRevenuePageState();
}

class _AddRevenuePageState extends State<AddRevenuePage> {
  String? selectedCategoryId;
  String? selectedCategoryName;

  Future<void> _pickCategory(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPickerPage(type: "revenue")));

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
  final _source = TextEditingController();
  final _date = TextEditingController();
  final _note = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
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

  Future<void> addRevenue() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('revenues')
        .add({
          'type': 'revenue',
          'value': double.tryParse(_value.text.trim()) ?? 0,
          'source': selectedCategoryId,
          'note': _note.text.trim(),
          'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Revenue added")));
    _value.clear();
    _source.clear();
    _date.clear();
    _note.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add new Revenue",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 70),
              Text("Value", style: theme.textTheme.bodySmall),
              const SizedBox(height: 7),
              TextField(
                style: theme.textTheme.bodyMedium,
                controller: _value,
                decoration: InputDecoration(hintText: "Ex: 409"),
              ),
              const SizedBox(height: 15),
              Text(
                "Source",
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
                  title: Text(selectedCategoryName ?? "Select Category", style: theme.textTheme.bodyMedium),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickCategory(context),
                ),
              ),
              const SizedBox(height: 15),
              Text("Note", style: theme.textTheme.bodySmall),
              const SizedBox(height: 7),
              TextField(
                style: theme.textTheme.bodyMedium,
                controller: _note,
                decoration: InputDecoration(
                  hintText: "Add any commentary you want",
                ),
              ),
              const SizedBox(height: 15),
              Text("Date", style: theme.textTheme.bodySmall),
              const SizedBox(height: 7),
              TextField(
                style: theme.textTheme.bodyMedium,
                controller: _date,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  hintText: 'Select a date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addRevenue,
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
