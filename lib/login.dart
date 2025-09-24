import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isEmailSelected = true;

  final fieldText = TextEditingController();

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+## ## #####-####',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.eager,

  );

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final theme = Theme.of(context);


    void clearText() {
      fieldText.clear();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(55),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  themeManager.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () => themeManager.toggleTheme(),
              ),
              Text(
                "Login",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                "Welcome back to Econance",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 35),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
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
                  TextButton(
                    onPressed: () {
                      clearText();
                      FocusScope.of(context).unfocus(); // Close keyboard
                      setState(() => isEmailSelected = false);
                    },
                    child: Text(
                      "Phone Number",
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
                ],
              ),
              const SizedBox(height: 35),

              Text(
                isEmailSelected ? "Email address" : "Phone number",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 5),

              TextField(
                controller: fieldText,
                keyboardType: isEmailSelected
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                inputFormatters: isEmailSelected
                    ? []
                    : [phoneFormatter],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: isEmailSelected
                      ? 'Enter your email'
                      : 'Enter your phone number',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  labelText: isEmailSelected
                      ? 'someone@gmail.com'
                      : '+55 11 99999-9999',
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 5),
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
