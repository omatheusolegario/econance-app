import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import 'register_verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String _uid = userCredential.user!.uid;
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(_uid);
      
      await userDoc.set({
          'personalInfo':{
            'fullName': _fullNameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          },
      });
      await userDoc.collection('expenses').doc('init').set({'init': true});
      await userDoc.collection('receipts').doc('init').set({'init': true});
      await userDoc.collection('categories').doc('init').set({'init': true});

      await Future.wait([
        userDoc.collection('expenses').doc('init').delete(),
        userDoc.collection('receipts').doc('init').delete(),
        userDoc.collection('categories').doc('init').delete()
      ]);

      await userCredential.user?.sendEmailVerification();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationPage(user: userCredential.user!),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String message = 'An error ocurred';
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The email is already in use.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.fullname,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 7),
                TextField(
                  style:  theme.textTheme.bodyMedium,
                  controller: _fullNameController,
                  decoration: InputDecoration(hintText: "Escreva seu nome completo"),
                ),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.emailaddress,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 7),
                TextField(
                  style:  theme.textTheme.bodyMedium,
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "someone@gmail.com"),
                ),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.password,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 7),
                TextField(
                  style:  theme.textTheme.bodyMedium,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.passwordinput,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: register,
                          child: const Text('Register'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
