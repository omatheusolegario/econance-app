import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../categories/category_picker.dart';

class EditTransactionPage extends StatefulWidget {
  final String type;
  final String transactionId;
  final String? initialDate;
  final String? initialValue;
  final List<Map<String, dynamic>>? initialItems;
  final String? initialCategoryId;
  final String? initialNote;

  const EditTransactionPage({
    super.key,
    required this.type,
    required this.transactionId,
    this.initialDate,
    this.initialValue,
    this.initialItems,
    this.initialCategoryId,
    this.initialNote,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _value = TextEditingController();
  final _note = TextEditingController();
  final _date = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCategoryId;
  String? selectedCategoryName;
  DateTime? _selectedDate;
  bool _isRecurrent = false;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _value.text = widget.initialValue ?? '';
    _note.text = widget.initialNote ?? '';

    if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.initialDate!);
        _date.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      } catch (e) {}
    }

    selectedCategoryId = widget.initialCategoryId;
    _items = widget.initialItems ?? [];
    _isRecurrent = false;

    if (selectedCategoryId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc(selectedCategoryId)
          .get()
          .then((doc) {
            if (doc.exists) {
              setState(() {
                selectedCategoryName = doc['name'];
              });
            }
          });
    }
  }

  Future<void> _pickCategory(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryPickerPage(type: widget.type)),
    );
    if (result != null) {
      setState(() {
        selectedCategoryId = result;
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('categories')
            .doc(result)
            .get()
            .then((doc) {
              selectedCategoryName = doc['name'];
              setState(() {});
            });
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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

  Future<void> _updateTransaction() async {
    final data = {
      'type': widget.type,
      'value': double.tryParse(_value.text.trim().replaceAll(',', '.')) ?? 0,
      'note': _note.text.trim(),
      'categoryId': selectedCategoryId,
      'isRecurrent': _isRecurrent,
      'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (_items.isNotEmpty) {
      data['items'] = _items
          .map((item) => {'name': item['name'], 'value': item['value']})
          .toList();
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(widget.type == "expense" ? "expenses" : "revenues")
        .doc(widget.transactionId)
        .update(data);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          right: 20,
          left: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 10),
              TextFormField(
                controller: _value,
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodyMedium,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Please enter a value";
                  if (double.tryParse(value.replaceAll(',', '.')) == null)
                    return "Enter a valid number";
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "500,00",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      top: 14,
                      bottom: 14,
                    ),
                    child: Text(
                      "R\$",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(hintText: "Optional note"),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  selectedCategoryName ?? "Select Category",
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickCategory(context),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _date,
                readOnly: true,
                onTap: _pickDate,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: "Select Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _isRecurrent,
                    onChanged: (val) =>
                        setState(() => _isRecurrent = val ?? false),
                  ),
                  Text("Is recurrent?", style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) _updateTransaction();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

