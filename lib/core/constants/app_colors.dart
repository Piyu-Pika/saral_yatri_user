import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (from the logo's blue)
  static const Color primary = Color(0xFF005B96); // Deep blue from the bus
  static const Color primaryLight = Color(0xFF6BA7D0); // Light blue from motion lines
  static const Color primaryDark = Color(0xFF003D66); // Darker shade of the bus blue

  // Secondary Colors (from the logo's red)
  static const Color secondary = Color(0xFFD13447); // Red from "saral" text
  static const Color secondaryLight = Color(0xFFE57B87); // Lighter red
  static const Color secondaryDark = Color(0xFFA02632); // Darker red

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD13447); // Using the red from logo
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF005B96); // Using primary blue

  // Surface Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Special Colors
  static const Color expired = Color(0xFFD13447); // Using secondary red
  static const Color mapMarker = Color(0xFF005B96); // Primary blue
  static const Color busMarker = Color(0xFF005B96); // Primary blue
  static const Color stationMarker = Color(0xFFD13447); // Secondary red

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary], // Blue to red gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
