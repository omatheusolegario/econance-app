import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/theme/theme_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _photoUrl;
  String? _name;
  String? _email;
  String? _phone;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    Color? confirmColor,
  }) async {
    final theme = Theme.of(context);
    return (await showDialog<bool>(
          context: context,
          builder: (_) => _buildDialog(
            title: title,
            content: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor ?? theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  AlertDialog _buildDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.primaryColor, width: 1),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    bool toggleable = false,
    VoidCallback? onToggle,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        suffixIcon: toggleable
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ListTile _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? theme.iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: color ?? theme.textTheme.bodyLarge?.color),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            )
          : null,
      onTap: onTap,
    );
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data()?['personalInfo'];

    setState(() {
      _name = data?['fullName'] ?? user.displayName ?? '';
      _email = user.email;
      _phone = data?['phone'] ?? '';
      _photoUrl = data?['photoUrl'] ?? user.photoURL ?? '';
    });
  }

  Future<void> _updateUser(
    String field,
    String newValue, {
    String? password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = _firestore.collection('users').doc(user.uid);

      switch (field) {
        case 'password':
          if (password == null || password.isEmpty) {
            throw 'Informe sua senha atual.';
          }
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(cred);
          await user.updatePassword(newValue);
          break;

        case 'name':
          await doc.update({'personalInfo.fullName': newValue});
          await user.updateDisplayName(newValue);
          setState(() => _name = newValue);
          break;

        case 'phone':
          await doc.update({'personalInfo.phone': newValue});
          setState(() => _phone = newValue);
          break;
      }

      _showMessage('$field atualizado com sucesso!');
    } catch (e) {
      _showMessage('Erro ao atualizar $field: $e');
    }
  }

  Future<void> _updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user == null) return _showMessage('Nenhum usuário logado.');

    if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      return _showMessage('Por favor, insira um email válido.');
    }
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);

      await user.verifyBeforeUpdateEmail(newEmail);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('Confirme seu email'),
            content: Text(
              'Um email de verificação foi enviado para $newEmail.\n'
              'Clique no link para concluir a atualização.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _attemptReLogin(newEmail, password);
                },
                child: const Text('Já confirmei, logar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showMessage('Erro ao atualizar email: $e');
    }
  }

  Future<void> _attemptReLogin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadUserData();
      _showMessage('Email atualizado e sessão restabelecida.');
    } catch (e) {
      _showMessage(
        'Não foi possível logar automaticamente. Faça login manualmente.',
      );
    }
  }

  Future<void> _logout() async {
    final theme = Theme.of(context);
    final confirm = await _confirmDialog(
      title: 'Sair da conta',
      message: 'Tem certeza que deseja sair?',
      confirmColor: theme.primaryColor,
    );
    if (!confirm) return;

    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Future<void> _deactivateAccount() async {
    final user = _auth.currentUser;
    final theme = Theme.of(context);
    if (user == null) return;

    final confirm = await _confirmDialog(
      title: 'Desativar conta',
      message: 'Deseja desativar temporariamente sua conta?',
      confirmColor: theme.primaryColor,
    );
    if (!confirm) return;

    await _firestore.collection('users').doc(user.uid).update({
      'status': 'inactive',
      'deactivatedAt': FieldValue.serverTimestamp(),
    });

    _showMessage('Conta desativada com sucesso.');
    await _logout();
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    final theme = Theme.of(context);
    if (user == null) return;

    final confirm = await _confirmDialog(
      title: 'Excluir conta',
      message: 'Essa ação é permanente. Deseja continuar?',
      confirmColor: theme.primaryColor,
    );
    if (!confirm) return;

    try {
      await _deleteUserSubcollections(user.uid, [
        'transactions',
        'categories',
        'somethingElse',
      ]);

      await _firestore.collection('users').doc(user.uid).delete();

      await user.delete();

      _showMessage('Conta excluída permanentemente.');
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      _showMessage('Erro ao excluir conta: $e');
    }
  }

  Future<void> _deleteUserSubcollections(
    String uid,
    List<String> subcollections,
  ) async {
    for (final subcollection in subcollections) {
      final colRef = _firestore
          .collection('users')
          .doc(uid)
          .collection(subcollection);
      final snapshots = await colRef.get();
      for (final doc in snapshots.docs) {
        await doc.reference.delete();
      }
    }
  }
  Future<void> _pickAndUploadProfileImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final ref = _storage.ref().child('user_profiles/${user.uid}/profile.jpg');
      await ref.putFile(File(pickedFile.path));

      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'personalInfo.photoUrl': url,
      });
      await user.updatePhotoURL(url);

      setState(() {
        _photoUrl = url;
        _isUploading = false;
      });

      _showMessage('Imagem atualizada com sucesso!');
    } catch (e) {
      setState(() => _isUploading = false);
      _showMessage('Erro ao atualizar imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);
    final divider = Divider(color: theme.dividerColor, thickness: 1, height: 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                          ? NetworkImage(_photoUrl!)
                          : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadProfileImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _name ?? '',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildListTile(
            icon: Icons.brightness_6,
            title: 'Theme',
            subtitle: themeManager.isDark ? 'Dark mode' : 'Light mode',
            onTap: () => themeManager.toggleTheme(),
          ),
          divider,
          _buildListTile(
            icon: Icons.person,
            title: 'Change Name',
            subtitle: _name,
            onTap: () => _showUpdateDialog('name'),
          ),
          divider,
          _buildListTile(
            icon: Icons.email,
            title: 'Change Email',
            subtitle: _email,
            onTap: () => _showUpdateDialog('email'),
          ),
          divider,
          _buildListTile(
            icon: Icons.phone,
            title: 'Change Phone',
            subtitle: _phone,
            onTap: () => _showUpdateDialog('phone'),
          ),
          divider,
          _buildListTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () => _showUpdateDialog('password'),
          ),
          divider,
          _buildListTile(
            icon: Icons.info,
            title: 'About us',
            subtitle: 'Learn more about Econance',
            onTap: () {},
          ),
          divider,
          _buildListTile(
            icon: Icons.pause_circle_filled,
            title: 'Deactivate Account',
            color: Colors.orange,
            onTap: _deactivateAccount,
          ),
          divider,
          _buildListTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            color: Colors.red,
            onTap: _deleteAccount,
          ),
          divider,
          _buildListTile(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(String field) {
    final controller = TextEditingController();
    final passwordController = TextEditingController();
    final theme = Theme.of(context);
    bool obscure = true;

    if (field == 'name') controller.text = _name ?? '';
    if (field == 'email') controller.text = _email ?? '';
    if (field == 'phone') controller.text = _phone ?? '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDialogState) {
          return _buildDialog(
            title: 'Update $field',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (field == 'email' || field == 'password')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTextField(
                      controller: passwordController,
                      hint: 'Current password',
                      obscure: obscure,
                      toggleable: true,
                      onToggle: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                _buildTextField(
                  controller: controller,
                  hint: 'New $field',
                  obscure: field == 'password' && obscure,
                  toggleable: field == 'password',
                  onToggle: field == 'password'
                      ? () => setDialogState(() => obscure = !obscure)
                      : null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (field == 'email') {
                    Navigator.pop(context);
                    await _updateEmail(
                      controller.text,
                      passwordController.text,
                    );
                  } else {
                    await _updateUser(
                      field,
                      controller.text,
                      password: passwordController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }
}
