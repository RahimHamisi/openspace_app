import 'package:flutter/material.dart';
import 'screens/intro_slider_screen.dart';
import 'screens/map_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart GIS App',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroSliderScreen(),
        '/map': (context) => const MapScreen(),
      },
    );
  }
}