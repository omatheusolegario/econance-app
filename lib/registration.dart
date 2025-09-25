import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
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

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerificationPage(user: userCredential.user!)));
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

  @override Widget build(BuildContext context){
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(padding: const EdgeInsets.all(55),
        child: Column(
          children:[

            TextField(controller: _emailController, decoration: InputDecoration(hintText: "someone@gmail.com"),),
            const SizedBox(height: 10),
            TextField(controller: _passwordController),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: register,child: const Text('Register'),),),
          ],
        )
      )
    );
  }

}
