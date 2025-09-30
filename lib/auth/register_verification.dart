import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';

class VerificationPage extends StatefulWidget {
  final User? user;
  final String? phoneNumber;
  final String? verificationId;

  const VerificationPage({
    super.key,
    this.user,
    this.phoneNumber,
    this.verificationId,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isVerified = false;
  bool _isLoading = false;
  final otpController = TextEditingController();

  Future<void> checkEmailVerified() async {
    if (widget.user == null) return;

    await widget.user!.reload();
    final user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      setState(() {
        _isVerified = true;
      });
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.notverified)),
      );
    }
  }

  Future<void> resendVerification() async {
    if (widget.user == null) return;

    await widget.user!.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.resendwarning)),
    );
  }

  Future<void> verifyPhoneOtp() async {
    if (widget.verificationId == null) return;

    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId!,
        smsCode: otpController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        _isVerified = true;
      });
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'OTP inválido')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isEmail = widget.user != null;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEmail
                  ? AppLocalizations.of(context)!.emailverification
                  : "Digite o código enviado para ${widget.phoneNumber}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            if (!isEmail)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Código OTP"),
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isEmail
                              ? checkEmailVerified
                              : verifyPhoneOtp,
                          child: Text(
                            isEmail
                                ? AppLocalizations.of(context)!.iverified
                                : "Verificar",
                          ),
                        ),
                      ),
                      if (isEmail) const SizedBox(height: 10),
                      if (isEmail)
                        TextButton(
                          onPressed: resendVerification,
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
