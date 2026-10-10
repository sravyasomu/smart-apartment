import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SmartApartmentApp());
}

class SmartApartmentApp extends StatelessWidget {
  const SmartApartmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Apartment',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8FF),
      ),
      home: const SplashScreen(),
    );
  }
}