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

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+## ## #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _isLoading = false;
  bool _obscurePassword = true;
  int _step = 0;

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
    String error = '';

    if (_step == 0 && _fullNameController.text.trim().isEmpty) {
      error = 'Digite seu nome completo';
    } else if (_step == 1) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        error = 'Digite um email válido';
      }
    } else if (_step == 2) {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.length < 10) {
        error = 'Digite um telefone válido';
      }
    } else if (_step == 3) {
      final pass = _passwordController.text.trim();
      if (pass.isEmpty || pass.length < 6) {
        error = 'A senha deve ter no mínimo 6 caracteres';
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verificação de email enviada')),
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

  Future<void> verifyEmail() async {
    setState(() => _isLoading = true);

    await _auth.currentUser?.reload();
    final user = _auth.currentUser!;
    bool emailVerified = user.emailVerified;

    setState(() => _isLoading = false);

    if (emailVerified) {
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email não verificado.')),
      );
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyEmail,
              child: const Text('Verificar Email'),
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
              "Complete seu cadastro",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 7),

            Text(
              getStepTitle(),
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
                  onPressed: nextStep,
                  child: const Text('Próximo'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
