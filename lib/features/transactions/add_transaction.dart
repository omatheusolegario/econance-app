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
    _items = widget.initialItems != null
        ? widget.initialItems!.map((e) => Map<String, dynamic>.from(e)).toList()
        : [];

    if (_items.isNotEmpty) {
      _updateTotalFromItems();
    }

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

  void _updateTotalFromItems() {
    double sum = 0;
    for (var item in _items) {
      sum += double.tryParse(item['value']?.toString().replaceAll(',', '.') ?? '0') ?? 0;
    }
    _value.text = sum.toStringAsFixed(2);
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

  Future<void> _saveTransaction() async {
    final service = TransactionService();

    await service.saveTransaction(
      type: widget.type,
      value: double.tryParse(_value.text.replaceAll(',', '.')) ?? 0,
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
      if (_selectedDate == null || selectedCategoryId == null || selectedCategoryId == '') {
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

  void _addOrEditItem({Map<String, dynamic>? existingItem}) {
    final theme = Theme.of(context);
    final nameCtrl = TextEditingController(text: existingItem?['name']);
    final valueCtrl = TextEditingController(text: existingItem?['value']?.toString());
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      existingItem == null ? "Add Item" : "Edit Item",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Item name",
                    hintText: "e.g. Laptop charger",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? "Please enter a name" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: valueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Value",
                    hintText: "e.g. 120.50",
                    prefixText: "R\$ ",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Please enter a value";
                    if (double.tryParse(v.replaceAll(',', '.')) == null) return "Enter a valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (existingItem != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _items.remove(existingItem);
                            _updateTotalFromItems();
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text("Remove", style: TextStyle(color: Colors.red)),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: Icon(existingItem == null ? Icons.add : Icons.save),
                      label: Text(existingItem == null ? "Add" : "Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final name = nameCtrl.text.trim();
                          final value = valueCtrl.text.trim();
                          setState(() {
                            if (existingItem != null) {
                              existingItem['name'] = name;
                              existingItem['value'] = value;
                            } else {
                              _items.add({'name': name, 'value': value});
                            }
                            _updateTotalFromItems();
                          });
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getCurrentPage() {
    final theme = Theme.of(context);
    String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
    final int successIndex = widget.isInvoice ? 3 : 2;

    if (_currentStep == successIndex) {
      return Center(
        key: ValueKey(_currentStep),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/animations/success.json", width: 150, repeat: false),
            const SizedBox(height: 20),
            Text("${capitalize(widget.type)} added successfully!",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
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
                });
              },
              child: Text("Add another ${capitalize(widget.type)}"),
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
                Text("Add ${capitalize(widget.type)}", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "First insert the value of the transaction, then a short commentary if you want to",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Please enter a value";
                    if (double.tryParse(value.replaceAll(',', '.')) == null) return "Enter a valid number";
                    return null;
                  },
                  controller: _value,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "500,00",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, top: 14, bottom: 14),
                      child: Text("R\$", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(controller: _note, style: theme.textTheme.bodyMedium, decoration: const InputDecoration(hintText: "Optional commentary")),
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
              Text("Details", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Choose category, date and recurrence", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 30),
              ListTile(
                title: Text(selectedCategoryName ?? "Select Category", style: theme.textTheme.bodyMedium),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickCategory(context),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _date,
                readOnly: true,
                onTap: _pickDate,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(hintText: "Date", suffixIcon: Icon(Icons.calendar_today)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isRecurrent,
                    onChanged: (val) => setState(() => _isRecurrent = val ?? false),
                  ),
                  Text("Is this recurrent?", style: theme.textTheme.bodyMedium),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isInvoice) ...[
                const SizedBox(height: 20),
                Text(
                  "Items",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._items.map(
                      (item) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_cart_outlined),
                      title: Text(item['name'] ?? ''),
                      subtitle: Text("R\$ ${item['value'] ?? ''}"),
                      trailing: const Icon(Icons.edit, color: Colors.grey),
                      onTap: () => _addOrEditItem(existingItem: item),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _addOrEditItem(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add New Item", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
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
                position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
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
