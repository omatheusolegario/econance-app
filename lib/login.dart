import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_verification.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isEmailSelected = true;
  bool _obscurePassword = true;
  final fieldText = TextEditingController();
  final passwordController = TextEditingController();

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+## ## #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  void clearText() {
    fieldText.clear();
  }

  Future<void> signInWithEmail() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: fieldText.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user!;
      if (!user.emailVerified) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VerificationPage(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.snackloginSuccess,
              )
                )
        );

        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ??  AppLocalizations.of(context)!.snackloginError,
      ),
      ),

      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.login,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      clearText();
                      FocusScope.of(context).unfocus(); // Close keyboard
                      setState(() => isEmailSelected = true);
                    },
                    child: Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 15,
                        color: isEmailSelected
                            ? Colors.green
                            : theme.textTheme.bodyMedium?.color,
                        decoration: isEmailSelected
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: Colors.green,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      clearText();
                      FocusScope.of(context).unfocus(); // Close keyboard
                      setState(() => isEmailSelected = false);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.phonenumber,
                      style: TextStyle(
                        fontSize: 15,
                        color: !isEmailSelected
                            ? Colors.green
                            : theme.textTheme.bodyMedium?.color,
                        decoration: !isEmailSelected
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: Colors.green,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: Icon(
                      themeManager.isDark ? Icons.dark_mode : Icons.light_mode,
                    ),
                    onPressed: () => themeManager.toggleTheme(),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Text(
                    isEmailSelected
                        ? AppLocalizations.of(context)!.emailaddress
                        : AppLocalizations.of(context)!.phonenumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),

                  const SizedBox(width: 40),

                ],
              ),
              const SizedBox(height: 5),

              TextField(
                controller: fieldText,
                keyboardType: isEmailSelected
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                inputFormatters: isEmailSelected ? [] : [phoneFormatter],
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: isEmailSelected
                      ? AppLocalizations.of(context)!.emailinput
                      : AppLocalizations.of(context)!.phoneinput,
                ),
              ),
              const SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.password,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/forgot-password");
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotpassword,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.passwordinput,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isEmailSelected) {
                      signInWithEmail();
                    } else {
                      //signInWithPhone();
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.login,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
