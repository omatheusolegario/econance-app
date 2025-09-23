import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black, fontSize: 14),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.green,
  scaffoldBackgroundColor:  const Color(0xFF1E1E1E),
  appBarTheme: const AppBarTheme(
    backgroundColor:  const Color(0xFF1E1E1E),
    foregroundColor:  const Color(0xFF1E1E1E),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white, fontSize: 14),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);