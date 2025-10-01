import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

class VerificationPage extends StatefulWidget {
  final User user;
  final String? verificationId;
  const VerificationPage({super.key, required this.user, this.verificationId});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isLoading = false;
  final otpController = TextEditingController();

  Future<bool> checkEmailVerified() async {
    await widget.user.reload();
    final user = FirebaseAuth.instance.currentUser!;
    return user.emailVerified;
  }

  Future<bool> verifySmsCode() async {
    if (widget.verificationId == null) return true;
    String smsCode = otpController.text.trim();
    if (smsCode.isEmpty) return false;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId!,
        smsCode: smsCode,
      );
      await widget.user.linkWithCredential(credential);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deu ruim")),
      );
      return false;
    }
  }

  Future<void> verifyAll() async {
    setState(() => _isLoading = true);

    bool emailOk = await checkEmailVerified();
    bool smsOk = await verifySmsCode();

    setState(() => _isLoading = false);

    if (emailOk && smsOk) {
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } else {
      String message = '';
      if (!emailOk) message += AppLocalizations.of(context)!.notverified + '\n';
      if (!smsOk) message += "Deu ruim";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> resendEmailVerification() async {
    await widget.user.sendEmailVerification();
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

            if (widget.verificationId != null) ...[
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'texto sms',
                  hintText: '123456',
                ),
              ),
              const SizedBox(height: 20),
            ],

            _isLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: verifyAll,
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
