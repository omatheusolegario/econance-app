import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _auth = FirebaseAuth.instance;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+## ## #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _isLoading = false;
  bool _obscurePassword = true;
  int _step = 0;

  double get progress => (_step + 1) / 4;

  String getStepTitle(BuildContext context) {
    switch (_step) {
      case 0:
        return AppLocalizations.of(context)!.stepFullName;
      case 1:
        return AppLocalizations.of(context)!.stepEmail;
      case 2:
        return AppLocalizations.of(context)!.stepPhone;
      case 3:
        return AppLocalizations.of(context)!.stepPasswordVerification;
      default:
        return '';
    }
  }

  void nextStep(BuildContext context) {
    String error = '';

    if (_step == 0 && _fullNameController.text.trim().isEmpty) {
      error = AppLocalizations.of(context)!.enterFullNameError;
    } else if (_step == 1) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        error = AppLocalizations.of(context)!.enterValidEmail;
      }
    } else if (_step == 2) {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.length < 10) {
        error = AppLocalizations.of(context)!.enterValidPhone;
      }
    } else if (_step == 3) {
      final pass = _passwordController.text.trim();
      if (pass.isEmpty || pass.length < 6) {
        error = AppLocalizations.of(context)!.passwordMin6;
      }
    }

    if (error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (_step < 3) {
      setState(() => _step++);
    }
  }

  Future<void> register() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(_fullNameController.text.trim());
      await userCredential.user!.reload();

      final uid = userCredential.user!.uid;
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      await userDoc.set({
        'personalInfo': {
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        }
      });

      await userCredential.user?.sendEmailVerification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.verificationEmailSent)),
      );
    } on FirebaseAuthException catch (e) {
      String msg = AppLocalizations.of(context)!.registrationError;
      if (e.code == 'weak-password') msg = AppLocalizations.of(context)!.weakPassword;
      if (e.code == 'email-already-in-use') msg = AppLocalizations.of(context)!.emailAlreadyInUse;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> verifyEmail() async {
    setState(() => _isLoading = true);

    await _auth.currentUser?.reload();
    final user = _auth.currentUser!;
    bool emailVerified = user.emailVerified;

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (emailVerified) {
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.emailNotVerified)),
      );
    }
  }

  Widget getStepWidget() {
    switch (_step) {
      case 0:
        return TextField(
          controller: _fullNameController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.enterFullNameLabel),
        );
      case 1:
        return TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.enterEmailLabel),
        );
      case 2:
        return TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [_phoneFormatter],
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.enterPhoneLabel,
            hintText: AppLocalizations.of(context)!.phoneHint,
          ),
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Digite sua senha',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register,
                child: Text(AppLocalizations.of(context)!.register),
              ),
            ),
            const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyEmail,
                child: Text(AppLocalizations.of(context)!.verifyEmail),
              ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            Text(
              AppLocalizations.of(context)!.completeRegistration,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 7),

            Text(
              getStepTitle(context),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(child: getStepWidget()),

            LinearProgressIndicator(value: progress),

            const SizedBox(height: 20),

            if (_step < 3)
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => nextStep(context),
                  child: Text(AppLocalizations.of(context)!.next),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
