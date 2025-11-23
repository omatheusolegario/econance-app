import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

class VerificationPage extends StatefulWidget {
  final User user;
  const VerificationPage({super.key, required this.user});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isLoading = false;

  Future<bool> checkEmailVerified() async {
    await widget.user.reload();
    final user = FirebaseAuth.instance.currentUser!;
    return user.emailVerified;
  }

  Future<void> verifyEmail() async {
    setState(() => _isLoading = true);

    bool emailOk = await checkEmailVerified();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (emailOk) {
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notverified),
        ),
      );
    }
  }

  Future<void> resendEmailVerification() async {
    await widget.user.sendEmailVerification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.resendwarning)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.emailverification,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: verifyEmail,
                    child: Text(AppLocalizations.of(context)!.iverified),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: resendEmailVerification,
                  child: Text(
                    AppLocalizations.of(context)!.resendverification,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
