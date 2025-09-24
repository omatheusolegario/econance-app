import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_verification.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'),),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true,),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: register, child: const Text('Register'),),
          ],
        )
      )
    );
  }

}
