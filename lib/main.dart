import 'package:econance/l10n/app_localizations.dart';
import 'package:econance/registration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome_page.dart';
import 'login.dart';
import 'theme_manager.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // from firebase_options.dart
  );
  runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeManager(),
        child: const EconanceApp(),
      )
  );
}

class EconanceApp extends StatelessWidget {
  const EconanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      supportedLocales: const[
        Locale('en'),
        Locale('pt'),
      ],
      localizationsDelegates: const[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('pt'),

      debugShowCheckedModeBanner: false,
      themeMode: themeManager.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      title: 'Econance',
      initialRoute: "/",
      routes: {
        "/": (context) => const WelcomePage(),
        "/login": (context) => const Login(),
        "/register": (context) => const RegistrationPage(),
      },


    );
  }
}
