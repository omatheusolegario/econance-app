import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF67D191),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 20),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
      bodySmall: TextStyle(color: Colors.black, fontSize: 10),
      labelMedium: TextStyle(color: Colors.white70, fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
    labelStyle: TextStyle(color: Color(0xFF9E9E9E)),
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
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

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF67D191),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.green[400],
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 20),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white, fontSize: 12),
      labelMedium: TextStyle(color: Colors.black87, fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,

    hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
    labelStyle: TextStyle(color: Color(0xFF9E9E9E)),
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
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
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF67D191),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),
);
