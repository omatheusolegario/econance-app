import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordResetSent)),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = AppLocalizations.of(context)!.errorOccurred;
      if (e.code == 'user-not-found') {
        message = AppLocalizations.of(context)!.noUserFoundForEmail;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
  appBar: AppBar(title: Text(AppLocalizations.of(context)!.forgotPasswordAppBar)),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.forgotPasswordTitle,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              AppLocalizations.of(context)!.recoverAccessSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 150),
            Text(
              AppLocalizations.of(context)!.resetInstruction,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            TextField(
              style: theme.textTheme.bodyMedium,
              controller: _emailController,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.templateemail),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text(AppLocalizations.of(context)!.sendResetLink),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
