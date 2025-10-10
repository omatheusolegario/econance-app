import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class AddInvestmentTypePage extends StatefulWidget {
  const AddInvestmentTypePage({super.key});

  @override
  State<AddInvestmentTypePage> createState() => _AddInvestmentTypePageState();
}

class _AddInvestmentTypePageState extends State<AddInvestmentTypePage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Type name cannot be empty")),
        );
        return;
      }
      _addType();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _addType() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('investments_types')
        .add({
      'name': _nameController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _currentStep = 1;
    });

    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildStepContent({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 26,
                left: 20,
                right: 20,
                bottom: 6,
              ),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 2,
                backgroundColor: Colors.grey.shade300,
                color: theme.primaryColor,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepContent(
                    title: "Add Investment Type",
                    subtitle:
                    "Give your type a name (e.g. Crypto, Stocks, Real Estate)",
                    child: TextField(
                      controller: _nameController,
                      style: theme.textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: "e.g. Crypto",
                      ),
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
                          "Type successfully added!",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep = 0;
                              _nameController.clear();
                            });
                            _pageController.animateToPage(
                              _currentStep,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text("Add another type"),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _currentStep == 0
          ? SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        ),
      )
          : null,
    );
  }
}
