import 'package:econance/add_expense.dart';
import 'package:econance/add_revenue.dart';
import 'package:econance/l10n/app_localizations.dart';
import 'package:econance/registration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'welcome_page.dart';
import 'login.dart';
import 'theme_manager.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'forgot_password.dart';
import 'home.dart';
import 'revenues_expenses..dart';

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
      routes: {
        "/welcome-page": (context) => const WelcomePage(),
        "/login": (context) => const Login(),
        "/register": (context) => const RegistrationPage(),
        "/forgot-password": (context) => const ForgotPasswordPage(),
        "/home": (context) => const HomePage(),
        "/revenues-expenses": (context) => const RevenuesExpensesPage(),
        "/add-revenue": (context) => const AddRevenuePage(),
        "/add-expense": (context) => const AddExpensePage(),
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper ({super.key});

  @override
  Widget build(BuildContext context){
    final user = FirebaseAuth.instance.currentUser;

    if (user!=null){
      WidgetsBinding.instance.addPostFrameCallback((_){
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route)=>false);
      });
      return const Scaffold();
    }
    return const WelcomePage();
  }
}
