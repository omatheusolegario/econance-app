import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF67D191),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 14),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF67D191),
  scaffoldBackgroundColor: const Color(0xFF1E1E1E),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFF1E1E1E),
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 24),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    ),
  ),
);
