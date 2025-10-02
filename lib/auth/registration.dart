import 'package:flutter/material.dart';
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
  final _smsController = TextEditingController();

  final _phoneFormatter =
  MaskTextInputFormatter(mask: '+## ## #####-####', filter: {"#": RegExp(r'[0-9]')});

  bool _isLoading = false;
  bool _obscurePassword = true;
  int _step = 0;
  String? _verificationId;

  double get progress => (_step + 1) / 4;

  String getStepTitle() {
    switch (_step) {
      case 0:
        return 'Nome completo';
      case 1:
        return 'Email';
      case 2:
        return 'Telefone';
      case 3:
        return 'Senha e Verificação';
      default:
        return '';
    }
  }

  void nextStep() {
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

      final uid = userCredential.user!.uid;
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      await userDoc.set({
        'personalInfo': {
          'fullName': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        }
      });

      await userCredential.user?.sendEmailVerification();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (cred) async {
          await userCredential.user?.linkWithCredential(cred);
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message ?? 'Erro SMS')));
        },
        codeSent: (verificationId, _) {
          setState(() => _verificationId = verificationId);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Código SMS enviado!')));
        },
        codeAutoRetrievalTimeout: (id) {},
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao registrar';
      if (e.code == 'weak-password') msg = 'Senha muito fraca';
      if (e.code == 'email-already-in-use') msg = 'Email já cadastrado';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> verifyEmailAndSms() async {
    setState(() => _isLoading = true);

    await _auth.currentUser?.reload();
    final user = _auth.currentUser!;
    bool emailVerified = user.emailVerified;

    bool smsVerified = true;
    if (_verificationId != null && _smsController.text.isNotEmpty) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _smsController.text.trim(),
        );
        await user.linkWithCredential(credential);
      } catch (_) {
        smsVerified = false;
      }
    }

    setState(() => _isLoading = false);

    if (emailVerified && smsVerified) {
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } else {
      String msg = '';
      if (!emailVerified) msg += 'Email não verificado.\n';
      if (!smsVerified) msg += 'Código SMS inválido.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget getStepWidget() {
    switch (_step) {
      case 0:
        return TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(labelText: 'Digite seu nome completo'),
        );
      case 1:
        return TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Digite seu email'),
        );
      case 2:
        return TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [_phoneFormatter],
          decoration: const InputDecoration(
            labelText: 'Digite seu telefone',
            hintText: '+55 11 99999-9999',
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
                child: const Text('Registrar'),
              ),
            ),
            if (_verificationId != null) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _smsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Código SMS',
                  hintText: '123456',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: verifyEmailAndSms,
                child: const Text('Verificar Email e SMS'),
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getStepTitle())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 20),
              Expanded(child: getStepWidget()),
              if (_step < 3)
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: nextStep,
                    child: const Text('Próximo'),
                  ),
                ),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
