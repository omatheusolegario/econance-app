import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:econance/features/investments_types/investment_type_picker.dart';

class EditInvestmentPage extends StatefulWidget {
  final String investmentId;
  final String? initialName;
  final String? initialType;
  final String? initialValue;
  final String? initialRate;
  final String? initialTargetValue;
  final String? initialStatus;
  final String? initialNotes;
  final String? initialDate;

  const EditInvestmentPage({
    super.key,
    required this.investmentId,
    this.initialName,
    this.initialType,
    this.initialValue,
    this.initialRate,
    this.initialTargetValue,
    this.initialStatus,
    this.initialNotes,
    this.initialDate,
  });

  @override
  State<EditInvestmentPage> createState() => _EditInvestmentPageState();
}

class _EditInvestmentPageState extends State<EditInvestmentPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  final _name = TextEditingController();
  final _type = TextEditingController();
  final _value = TextEditingController();
  final _rate = TextEditingController();
  final _targetValue = TextEditingController();
  final _notes = TextEditingController();
  final _date = TextEditingController();

  String? _status;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName ?? '';
    _type.text = widget.initialType ?? '';
    _value.text = widget.initialValue ?? '';
    _rate.text = widget.initialRate ?? '';
    _targetValue.text = widget.initialTargetValue ?? '';
    _status = widget.initialStatus;
    _notes.text = widget.initialNotes ?? '';

    if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.initialDate!);
        _date.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      } catch (_) {}
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _date.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickType() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InvestmentTypePickerPage()),
    );
    if (result != null && result is String) {
      setState(() {
        _type.text = result;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _name.text.trim(),
      'type': _type.text.trim(),
      'value': double.tryParse(_value.text.replaceAll(',', '.')) ?? 0,
      'rate': double.tryParse(_rate.text) ?? 0,
      'targetValue': double.tryParse(_targetValue.text) ?? 0,
      'status': _status,
      'notes': _notes.text.trim(),
      'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments')
        .doc(widget.investmentId)
        .update(data);

    Navigator.pop(context);
  }

  Widget _label(String text, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _stepGeneralInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Name", context),
        TextFormField(
          controller: _name,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(hintText: "e.g. Bitcoin"),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 20),
        _label("Type", context),
        TextFormField(
          controller: _type,
          readOnly: true,
          onTap: _pickType,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(
            hintText: "Select type",
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _stepFinancials(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Invested Value (R\$)", context),
        TextFormField(
          controller: _value,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(hintText: "1000"),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 20),
        _label("Target Value (R\$)", context),
        TextFormField(
          controller: _targetValue,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(hintText: "3000"),
        ),
        const SizedBox(height: 20),
        _label("Rate (%)", context),
        TextFormField(
          controller: _rate,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(hintText: "0.0021"),
        ),
      ],
    );
  }

  Widget _stepStatusNotes(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Status", context),
        DropdownButtonFormField<String>(
          value: _status,
          style: theme.textTheme.bodyMedium,
          items: const [
            DropdownMenuItem(value: "active", child: Text("Active")),
            DropdownMenuItem(value: "closed", child: Text("Closed")),
          ],
          onChanged: (v) => setState(() => _status = v),
          decoration: const InputDecoration(hintText: "Select status"),
        ),
        const SizedBox(height: 20),
        _label("Date", context),
        TextField(
          controller: _date,
          readOnly: true,
          onTap: _pickDate,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(
            hintText: "Select date",
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 20),
        _label("Notes", context),
        TextField(
          controller: _notes,
          maxLines: 2,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(hintText: "Optional observations"),
        ),
      ],
    );
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _save();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = ["General", "Financials", "Status & Notes"];

    return SingleChildScrollView(
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              steps[_currentPage],
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Edit Investment",
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                steps.length,
                    (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentPage
                          ? theme.primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _stepGeneralInfo(context),
                  _stepFinancials(context),
                  _stepStatusNotes(context),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _prevPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(120, 45),
                    ),
                    child: const Text("← Back"),
                  )
                else
                  const SizedBox(width: 120),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 45),
                  ),
                  child: Text(_currentPage == 2 ? "Save" : "Next →"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
