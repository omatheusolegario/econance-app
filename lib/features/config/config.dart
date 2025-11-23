import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/theme/theme_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';
import 'package:econance/theme/responsive_colors.dart';
import 'about_page.dart';

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

  String _resolveLocalized(
    Object? prop,
    String value, {
    String placeholder = '{field}',
    String? defaultTemplate,
  }) {
    if (prop is String) {
      return prop.replaceFirst(placeholder, value);
    }
    try {
      return (prop as dynamic)(value) as String;
    } catch (_) {}
    if (defaultTemplate != null)
      return defaultTemplate.replaceFirst(placeholder, value);
    return value;
  }

  String _safeLanguage(AppLocalizations l10n) {
    final dyn = l10n as dynamic;
    try {
      return dyn.language as String;
    } catch (_) {
      return 'Language';
    }
  }

  String _safeEnglish(AppLocalizations l10n) {
    final dyn = l10n as dynamic;
    try {
      return dyn.english as String;
    } catch (_) {
      return 'English';
    }
  }

  String _safePortuguese(AppLocalizations l10n) {
    final dyn = l10n as dynamic;
    try {
      return dyn.portuguese as String;
    } catch (_) {
      return 'Português';
    }
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.cancel,
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
                child: Text(
                  l10n.confirm,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: ResponsiveColors.hint(theme)),
        suffixIcon: toggleable
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: ResponsiveColors.hint(theme),
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

    final l10n = AppLocalizations.of(context)!;
    String localizedFieldNoun;
    switch (field) {
      case 'name':
        localizedFieldNoun = l10n.nameLabel;
        break;
      case 'email':
        localizedFieldNoun = l10n.emailaddress;
        break;
      case 'phone':
        localizedFieldNoun = l10n.phonenumber;
        break;
      case 'password':
        localizedFieldNoun = l10n.password;
        break;
      default:
        localizedFieldNoun = field;
    }

    try {
      final doc = _firestore.collection('users').doc(user.uid);

      switch (field) {
        case 'password':
          if (password == null || password.isEmpty) {
            throw l10n.enterCurrentPassword;
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

      // Show localized success message using the {field} placeholder
      final updateSuccessProp = l10n.updateSuccess;
      final successMessage = _resolveLocalized(
        updateSuccessProp,
        localizedFieldNoun,
        placeholder: '{field}',
        defaultTemplate: '{field} updated successfully!',
      );

      _showMessage(successMessage);
    } catch (e) {
      _showMessage('${l10n.errorOccurred}: $e');
    }
  }

  Future<void> _updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    final l10n = AppLocalizations.of(context)!;
    if (user == null) return _showMessage(l10n.noUserLoggedIn);

    if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      return _showMessage(l10n.enterValidEmail);
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
          final l10n = AppLocalizations.of(context)!;
          String emailDialogContent;
          final emailContentProp = l10n.emailVerificationSentContent;
          if (emailContentProp is String) {
            emailDialogContent = (emailContentProp as String).replaceFirst(
              '{email}',
              newEmail,
            );
          } else {
            try {
              emailDialogContent =
                  (emailContentProp as dynamic)(newEmail) as String;
            } catch (_) {
              emailDialogContent = _resolveLocalized(
                emailContentProp,
                newEmail,
                placeholder: '{email}',
                defaultTemplate:
                    'An email verification was sent to {email}.\nClick the link to complete the update.',
              );
            }
          }

          return AlertDialog(
            title: Text(l10n.confirmYourEmail),
            content: Text(emailDialogContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _attemptReLogin(newEmail, password);
                },
                child: Text(l10n.iHaveConfirmedLogin),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showMessage('${l10n.errorOccurred}: $e');
    }
  }

  Future<void> _attemptReLogin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadUserData();
      final l10n = AppLocalizations.of(context)!;
      _showMessage(l10n.emailUpdatedAndReauthenticated);
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showMessage(l10n.reloginFailed);
    }
  }

  Future<void> _logout() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final confirm = await _confirmDialog(
      title: l10n.logoutTitle,
      message: l10n.logoutContent,
      confirmColor: theme.primaryColor,
    );
    if (!confirm) return;

    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    final theme = Theme.of(context);
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;

    final confirm = await _confirmDialog(
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountContent,
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

      _showMessage(l10n.accountDeleted);
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      _showMessage('${l10n.errorOccurred}: $e');
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

    final l10n = AppLocalizations.of(context)!;

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
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
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

      _showMessage(l10n.imageUpdatedSuccess);
    } catch (e) {
      setState(() => _isUploading = false);
      _showMessage('${l10n.imageUpdateError}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final divider = Divider(
      color: theme.dividerColor,
      thickness: .2,
      height: 1,
    );

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
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
                      backgroundImage:
                          _photoUrl != null && _photoUrl!.isNotEmpty
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
                          child: Icon(
                            Icons.camera_alt,
                            color: ResponsiveColors.onPrimary(theme),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _name ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildListTile(
            icon: Icons.brightness_6,
            title: l10n.theme,
            subtitle: themeManager.isDark ? l10n.darkMode : l10n.lightMode,
            onTap: () => themeManager.toggleTheme(),
          ),
          divider,
          _buildListTile(
            icon: Icons.person,
            title: l10n.changeName,
            subtitle: _name,
            onTap: () => _showUpdateDialog('name'),
          ),
          divider,
          _buildListTile(
            icon: Icons.email,
            title: l10n.changeEmail,
            subtitle: _email,
            onTap: () => _showUpdateDialog('email'),
          ),
          divider,
          _buildListTile(
            icon: Icons.phone,
            title: l10n.changePhone,
            subtitle: _phone,
            onTap: () => _showUpdateDialog('phone'),
          ),
          divider,
          _buildListTile(
            icon: Icons.lock,
            title: l10n.changePassword,
            onTap: () => _showUpdateDialog('password'),
          ),
          divider,
          _buildListTile(
            icon: Icons.info,
            title: l10n.aboutUs,
            subtitle: l10n.aboutUsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),
          divider,
          _buildListTile(
            icon: Icons.language,
            title: _safeLanguage(l10n),
            subtitle: themeManager.locale.languageCode == 'pt'
                ? _safePortuguese(l10n)
                : _safeEnglish(l10n),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: Text(_safeLanguage(l10n)),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'pt'),
                      child: Text(_safePortuguese(l10n)),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'en'),
                      child: Text(_safeEnglish(l10n)),
                    ),
                  ],
                ),
              );

              if (selected != null) {
                themeManager.setLocale(Locale(selected));
                _showMessage(selected == 'pt'
                    ? _safePortuguese(l10n)
                    : _safeEnglish(l10n));
              }
            },
          ),
          divider,
          _buildListTile(
            icon: Icons.delete_forever,
            title: l10n.deleteAccountTitle,
            color: ResponsiveColors.error(theme),
            onTap: _deleteAccount,
          ),
          divider,
          _buildListTile(
            icon: Icons.logout,
            title: l10n.logoutTitle,
            color: ResponsiveColors.error(theme),
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
          final l10n = AppLocalizations.of(context)!;

          // Use the localized noun for the field (Name, Email, Phone, Password)
          String localizedFieldNoun;
          switch (field) {
            case 'name':
              localizedFieldNoun = l10n.nameLabel;
              break;
            case 'email':
              localizedFieldNoun = l10n.emailaddress;
              break;
            case 'phone':
              localizedFieldNoun = l10n.phonenumber;
              break;
            case 'password':
              localizedFieldNoun = l10n.password;
              break;
            default:
              localizedFieldNoun = field;
          }

          // Resolve title which may be a String with placeholder or a generated method.
          final titleProp = l10n.updateField;
          final resolvedTitle = _resolveLocalized(
            titleProp,
            localizedFieldNoun,
            placeholder: '{field}',
            defaultTemplate: 'Update {field}',
          );

          // Resolve new field hint similarly using the noun label.
          final newFieldProp = l10n.newField;
          final resolvedNewFieldHint = _resolveLocalized(
            newFieldProp,
            localizedFieldNoun,
            placeholder: '{field}',
            defaultTemplate: 'New {field}',
          );

          return _buildDialog(
            title: resolvedTitle,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (field == 'email' || field == 'password')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTextField(
                      controller: passwordController,
                      hint: l10n.currentPassword,
                      obscure: obscure,
                      toggleable: true,
                      onToggle: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                _buildTextField(
                  controller: controller,
                  hint: resolvedNewFieldHint,
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
                  l10n.cancel,
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
                child: Text(AppLocalizations.of(context)!.update),
              ),
            ],
          );
        },
      ),
    );
  }
}
