import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'register_verification.dart';
import 'theme_manager.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(55),
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
    );
  }
}
