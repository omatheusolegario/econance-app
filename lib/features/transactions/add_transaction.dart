import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../categories/category_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:econance/services/transaction_service.dart';

class AddTransactionPage extends StatefulWidget {
  final String type;
  final bool isInvoice;
  final String? initialDate;
  final String? initialValue;
  final List<Map<String, dynamic>>? initialItems;
  final String? initialCategoryId;
  final String? initialNote;

  const AddTransactionPage({
    super.key,
    required this.type,
    this.isInvoice = false,
    this.initialDate,
    this.initialValue,
    this.initialItems,
    this.initialCategoryId,
    this.initialNote,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
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

  int _currentStep = 0;
  final PageController _pageController = PageController();

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
    final service = TransactionService();

    await service.saveTransaction(
      type: widget.type,
      value: double.tryParse(_value.text.trim()) ?? 0,
      note: _note.text.trim(),
      categoryId: selectedCategoryId,
      isRecurrent: _isRecurrent,
      selectedDate: _selectedDate,
      isInvoice: widget.isInvoice,
      items: _items,
    );

    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 1) {
      if (_selectedDate == null ||
          selectedCategoryId == null ||
          selectedCategoryId == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields first")),
        );
        return;
      }
      if (!widget.isInvoice) {
        setState(() {
          _currentStep++;
          _saveTransaction();
        });
      } else {
        setState(() {
          _currentStep++;
        });
      }
    } else if (widget.isInvoice && _currentStep == 2) {
      setState(() {
        _currentStep++;
        _saveTransaction();
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _getCurrentPage() {
    final theme = Theme.of(context);
    String capitalize(String s) =>
        s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
    final int successIndex = widget.isInvoice ? 3 : 2;

    if (_currentStep == successIndex) {
      return Center(
        key: ValueKey(_currentStep),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset("assets/animations/success.json",
                width: 150, repeat: false),
            const SizedBox(height: 20),
            Text(
              "${capitalize(widget.type)} added successfully!",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            if (!widget.isInvoice)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _value.text = '';
                    _date.text = '';
                    selectedCategoryId = '';
                    selectedCategoryName = "Select Category";
                    _selectedDate = null;
                    _note.text = '';
                    _items.clear();
                    _getCurrentPage();
                  });
                },
                child: Text("   Add another ${capitalize(widget.type)}   "),
              ),
          ],
        ),
      );
    }

    switch (_currentStep) {
      case 0:
        return Padding(
          key: ValueKey(_currentStep),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Form(
            key: _formKey,
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
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a value";
                    }
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                  controller: _value,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "500,00",
                    prefixIcon: Padding(
                      padding:
                      const EdgeInsets.only(left: 14, top: 14, bottom: 14),
                      child: Text(
                        "R\$",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _note,
                  style: theme.textTheme.bodyMedium,
                  decoration:
                  const InputDecoration(hintText: "Optional commentary"),
                ),
              ],
            ),
          ),
        );

      case 1:
        return Padding(
          key: ValueKey(_currentStep),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Details",
                style:
                theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose category, date and recurrence",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ListTile(
                title: Text(selectedCategoryName ?? "Select Category",
                    style: theme.textTheme.bodyMedium),
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
                  Text("Is this recurrent?",
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        );

      case 2:
        return Padding(
          key: ValueKey(_currentStep),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            children: [
              if (widget.isInvoice) ...[
                const SizedBox(height: 20),
                Text(
                  "Items",
                  style:
                  theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._items.map(
                      (item) => ListTile(
                    title: Text(item['name'] ?? ''),
                    trailing: Text('R\$ ${item['value'] ?? ''}'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final nameCtrl = TextEditingController();
                        final valueCtrl = TextEditingController();
                        return AlertDialog(
                          title: const Text("Add Item"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                  controller: nameCtrl,
                                  decoration: const InputDecoration(
                                      hintText: "Name")),
                              TextField(
                                controller: valueCtrl,
                                decoration: const InputDecoration(
                                    hintText: "Value"),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (nameCtrl.text.isNotEmpty &&
                                    valueCtrl.text.isNotEmpty) {
                                  setState(() {
                                    _items.add({
                                      'name': nameCtrl.text.trim(),
                                      'value': valueCtrl.text.trim(),
                                    });
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Add New Item"),
                ),
              ],
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int numPages = widget.isInvoice ? 4 : 3;
    final int numInputSteps = widget.isInvoice ? 3 : 2;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10.0,
          right: 20.0,
          left: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / numPages,
                backgroundColor: Colors.grey.shade300,
                color: theme.primaryColor,
                minHeight: 4,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
              child: _getCurrentPage(),
            ),
            const SizedBox(height: 10),
            if (_currentStep < numInputSteps)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStep > 0)
                    FloatingActionButton(
                      heroTag: "backBtn",
                      onPressed: _previousStep,
                      backgroundColor: Colors.grey,
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                  const Spacer(),
                  FloatingActionButton(
                    onPressed: _nextStep,
                    backgroundColor: theme.primaryColor,
                    child: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
