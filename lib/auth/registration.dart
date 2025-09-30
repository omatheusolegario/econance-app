import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../l10n/app_localizations.dart';
import 'register_verification.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool isEmailSelected = true;

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+## ## #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  void clearText() {
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
  }

  Future<void> register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (isEmailSelected) {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String _uid = userCredential.user!.uid;
        DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(_uid);

        await userDoc.set({
          'personalInfo': {
            'fullName': _fullNameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'email': _emailController.text.trim(),
          },
        });
        await Future.wait([
          userDoc.collection('expenses').doc('init').set({'init': true}),
          userDoc.collection('receipts').doc('init').set({'init': true}),
          userDoc.collection('categories').doc('init').set({'init': true}),
        ]);
        await Future.wait([
          userDoc.collection('expenses').doc('init').delete(),
          userDoc.collection('receipts').doc('init').delete(),
          userDoc.collection('categories').doc('init').delete(),
        ]);

        await userCredential.user?.sendEmailVerification();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationPage(user: userCredential.user!),
          ),
        );
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: _phoneController.text.trim(),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? 'Phone auth failed')));
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerificationPage(
                  phoneNumber: _phoneController.text.trim(),
                  verificationId: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The email is already in use.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.createAccount,
                style: theme.textTheme.headlineLarge
                    ?.copyWith(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      clearText();
                      setState(() => isEmailSelected = true);
                    },
                    child: Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 15,
                        color: isEmailSelected ? Colors.green : theme.textTheme.bodyMedium?.color,
                        decoration: isEmailSelected ? TextDecoration.underline : TextDecoration.none,
                        decorationColor: Colors.green,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      clearText();
                      setState(() => isEmailSelected = false);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.phonenumber,
                      style: TextStyle(
                        fontSize: 15,
                        color: !isEmailSelected ? Colors.green : theme.textTheme.bodyMedium?.color,
                        decoration: !isEmailSelected ? TextDecoration.underline : TextDecoration.none,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.fullname,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(hintText: "Escreva seu nome completo"),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Text(
                isEmailSelected ? AppLocalizations.of(context)!.emailaddress : AppLocalizations.of(context)!.phonenumber,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              TextField(
                controller: isEmailSelected ? _emailController : _phoneController,
                keyboardType: isEmailSelected ? TextInputType.emailAddress : TextInputType.phone,
                inputFormatters: isEmailSelected ? [] : [phoneFormatter],
                decoration: InputDecoration(
                  hintText: isEmailSelected ? "someone@gmail.com" : "+55 11 91234-5678",
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),

                Text(
                  AppLocalizations.of(context)!.password,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.passwordinput,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),

              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: register,
                  child: const Text('Registrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
