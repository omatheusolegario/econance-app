import 'package:econance/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationPage extends StatefulWidget {
  final User user;
  const VerificationPage({super.key, required this.user});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isVerified = false;
  bool _isLoading = false;

  Future<void> checkEmailVerified() async {
    await widget.user.reload();
    final user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      setState(() {
        _isVerified = true;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email not verified yet!')));
    }
  }

  Future<void> resendVerification() async {
    await widget.user.sendEmailVerification();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email resent!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification email has been sent. Please check your email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: checkEmailVerified,
                        child: const Text('I have verified'),
                      ),
                      TextButton(
                        onPressed: resendVerification,
                        child: const Text('Resend verification email'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
