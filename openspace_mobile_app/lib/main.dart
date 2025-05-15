import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
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
        '/home': (context) => const HomePage(),
        // '/reported_issues': (context) => const Placeholder(),
        // '/track_progress': (context) => const Placeholder(),
        // '/book_space': (context) => const Placeholder(),
        // '/profile': (context) => const Placeholder(),
        '/map': (context) => const MapScreen(),

      },
    );
  }
}