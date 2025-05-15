import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/screens/reported_issue.dart';
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
        '/home': (context) => const IntroSliderScreen(),
        '/reported_issue/': (context) => const HomePage(),
        // '/reported_issues': (context) => const Placeholder(),
        // '/track_progress': (context) => const Placeholder(),
        // '/book_space': (context) => const Placeholder(),
        // '/profile': (context) => const Placeholder(),
        '/map': (context) => const MapScreen(),
        '/':(context) => const ReportedIssuesPage(),

      },
    );
  }
}