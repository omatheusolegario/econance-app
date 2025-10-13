import 'package:econance/auth/registration.dart';
import 'package:econance/l10n/app_localizations.dart';
import 'package:econance/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import '../onboarding/welcome_page.dart';
import '../auth/login.dart';
import '../theme/theme_manager.dart';
import '../theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../auth/forgot_password.dart';
import '../features/home/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        "/home": (context) => const HomePage(hideSensitive: true),
        "/main": (context) => const MainScreen(),
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
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route)=>false);
      });
      return const Scaffold();
    }
    return const WelcomePage();
  }
}