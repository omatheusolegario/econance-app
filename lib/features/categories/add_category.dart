import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  String? type;
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if(_currentStep == 1){
      _addCategory();
    }
  }

  Future<void> _addCategory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .add({
          'name': _nameController.text.trim(),
          'type': type,
          'createdAt': FieldValue.serverTimestamp(),
        });

    setState(() {
      _currentStep++;
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
      padding: const EdgeInsets.all(30),
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
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: Colors.white10,
                color: theme.primaryColor,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepContent(
                    title: "Add Category",
                    subtitle: "Give your category a name",
                    child: TextField(
                      controller: _nameController,
                      style: theme.textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: "e.g. Groceries, Salary",
                      ),
                    ),
                  ),
                  _buildStepContent(
                    title: "Choose the type",
                    subtitle: "Is your category an expense or a revenue?",
                    child: DropdownButtonFormField<String>(
                      initialValue: "expense",
                      style: theme.textTheme.bodyMedium,
                      items: const [
                        DropdownMenuItem(
                          value: "expense",
                          child: Text("Expense"),
                        ),
                        DropdownMenuItem(
                          value: "revenue",
                          child: Text("Revenue"),
                        ),
                      ],
                      onChanged: (val) => setState(() => type = val),
                      decoration:InputDecoration(hintText: "Select a type"),
                    ),
                  ),
                  Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        "assets/animations/success.json",
                        width: 150,
                        repeat: false
                      ),
                      const SizedBox(height: 20,),
                      Text("Category successfully added!", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),)
                    ],
                  ),)
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:  _currentStep < 2 ? FloatingActionButton(onPressed: _nextStep, backgroundColor: theme.primaryColor,child: const Icon(Icons.arrow_forward_ios),) : null
    );
  }
}
