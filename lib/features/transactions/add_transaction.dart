import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../categories/category_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class AddTransactionPage extends StatefulWidget {
  final String type;

  const AddTransactionPage({super.key, required this.type});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _value = TextEditingController();
  final _note = TextEditingController();
  final _date = TextEditingController();

  String? selectedCategoryId;
  String? selectedCategoryName;
  DateTime? _selectedDate;
  bool _isRecurrent = false;

  int _currentStep = 0;
  final PageController _pageController = PageController();

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

  Future<void> _saveTransaction() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(widget.type == "expense" ? "expenses" : "revenues")
        .add({
          'type': widget.type,
          'value': double.tryParse(_value.text.trim()) ?? 0,
          'note': _note.text.trim(),
          'categoryId': selectedCategoryId,
          'isRecurrent': _isRecurrent,
          'date': _selectedDate != null
              ? Timestamp.fromDate(_selectedDate!)
              : null,
          'createdAt': FieldValue.serverTimestamp(),
        });

    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      _saveTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: Colors.grey.shade300,
                color: theme.primaryColor,
                minHeight: 4,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add ${capitalize(widget.type)}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "First insert the value of the transaction, then a short commentary if you want to",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: _value,
                          keyboardType: TextInputType.number,
                          style: theme.textTheme.bodyMedium,

                          decoration: InputDecoration(
                            hintText: "500,00",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 14, top: 14, bottom: 14),
                              child: Text(
                                "R\$",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _note,
                          style: theme.textTheme.bodyMedium,
                          decoration: const InputDecoration(
                            hintText: "Optional commentary",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Details",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Choose category, date and recurrence",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ListTile(
                          title: Text(
                            selectedCategoryName ?? "Select Category",
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _pickCategory(context),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _date,
                          readOnly: true,
                          onTap: _pickDate,
                          style: theme.textTheme.bodyMedium,
                          decoration: const InputDecoration(
                            hintText: "Date",
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: _isRecurrent,
                              onChanged: (val) {
                                setState(() => _isRecurrent = val ?? false);
                              },
                            ),
                            Text(
                              "Is this recurrent?",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/animations/success.json",
                          width: 150,
                          repeat: false,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${capitalize(widget.type)} added succesfully!",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentStep < 2
          ? FloatingActionButton(
              onPressed: _nextStep,
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.arrow_forward_ios),
            )
          : null,
    );
  }
}
