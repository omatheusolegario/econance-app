import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:econance/features/investments_types/investment_type_picker.dart';
import '../../l10n/app_localizations.dart';

class StepHeader extends StatelessWidget {
  final String title;
  final String description;

  const StepHeader({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class AddInvestmentPage extends StatefulWidget {
  final String uid;
  const AddInvestmentPage({super.key, required this.uid});

  @override
  State<AddInvestmentPage> createState() => _AddInvestmentPageState();
}

class _AddInvestmentPageState extends State<AddInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  final _name = TextEditingController();
  final _type = TextEditingController();
  final _value = TextEditingController();
  final _rate = TextEditingController();
  final _targetValue = TextEditingController();
  final _notes = TextEditingController();
  final _date = TextEditingController();

  String? _status;
  DateTime? _selectedDate;

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
      MaterialPageRoute(builder: (_) => InvestmentTypePickerPage(uid: widget.uid)),
    );
    if (result != null && result is String) {
      setState(() {
        _type.text = result;
      });
    }
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final data = {
      'name': _name.text.trim(),
      'type': _type.text.trim(),
      'value': double.tryParse(_value.text.replaceAll(',', '.')) ?? 0,
      'rate': double.tryParse(_rate.text) ?? 0,
      'targetValue': double.tryParse(_targetValue.text) ?? 0,
      'status': _status,
      'notes': _notes.text.trim(),
      'date': Timestamp.fromDate(_selectedDate!),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('investments')
        .add(data);

    setState(() {
      _currentStep = 3;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _name.clear();
    _type.clear();
    _value.clear();
    _rate.clear();
    _targetValue.clear();
    _notes.clear();
    _date.clear();
    _status = null;
    _selectedDate = null;
    _pageController.jumpToPage(0);
    setState(() {
      _currentStep = 0;
    });
  }

  InputDecoration _textFieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Widget _stepGeneralInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: AppLocalizations.of(context)!.investmentInfo,
            description: AppLocalizations.of(context)!.enterInvestmentInfo,
          ),
          Text(AppLocalizations.of(context)!.nameLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _name,
            validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration(AppLocalizations.of(context)!.exampleBitcoinHint),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.typeLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _type,
            readOnly: true,
            onTap: _pickType,
            validator: (v) => v == null || v.isEmpty ? "Required" : null,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration(
              AppLocalizations.of(context)!.selectType,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepFinancials() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: AppLocalizations.of(context)!.financialInfo,
            description: AppLocalizations.of(context)!.enterFinancialInfo,
          ),
          Text(AppLocalizations.of(context)!.investedValueLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _value,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration("1000"),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.targetValueLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _targetValue,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration("3000"),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.rateLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _rate,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration("0.0021"),
          ),
        ],
      ),
    );
  }

  Widget _stepStatusNotes() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: AppLocalizations.of(context)!.statusNotes,
            description: AppLocalizations.of(context)!.selectStatusDateAndNotes,
          ),
          Text(AppLocalizations.of(context)!.statusLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _status,
            validator: (v) => v == null ? "Required" : null,
            items: [
              DropdownMenuItem(value: "active", child: Text(AppLocalizations.of(context)!.active)),
              DropdownMenuItem(value: "closed", child: Text(AppLocalizations.of(context)!.closed)),
            ],
            onChanged: (v) => setState(() => _status = v),
            decoration: _textFieldDecoration(AppLocalizations.of(context)!.selectStatus),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.dateLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _date,
            readOnly: true,
            onTap: _pickDate,
            validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration(
              AppLocalizations.of(context)!.selectDate,
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.notesLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          TextFormField(
            controller: _notes,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _textFieldDecoration(AppLocalizations.of(context)!.optionalObservations),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentStep() {
    if (_currentStep == 3) {
      return Center(
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
              AppLocalizations.of(context)!.investmentAddedSuccessfully,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetForm,
              child: Text(AppLocalizations.of(context)!.addAnotherInvestment),
            ),
          ],
        ),
      );
    }

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [_stepGeneralInfo(), _stepFinancials(), _stepStatusNotes()],
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep++);
      } else {
        _saveInvestment();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isPortrait = constraints.maxHeight > constraints.maxWidth;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: isPortrait ? double.infinity : 400,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isPortrait ? 0 : (maxWidth - 400) / 2,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / 4,
                        backgroundColor: Colors.grey.shade300,
                        color: theme.primaryColor,
                        minHeight: 4,
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: _getCurrentStep()),
                      const SizedBox(height: 20),
                      if (_currentStep < 3)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep > 0)
                              FloatingActionButton(
                                heroTag: "backBtn",
                                onPressed: _prevStep,
                                backgroundColor: Colors.grey,
                                child: const Icon(Icons.arrow_back_ios),
                              )
                            else
                              const SizedBox(width: 40),
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
              ),
            );
          },
        ),
      ),
    );
  }
}