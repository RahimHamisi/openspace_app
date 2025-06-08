import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/providers/locale_provider.dart';
import 'package:openspace_mobile_app/providers/theme_provider.dart';
import 'package:openspace_mobile_app/screens/helps_and_Faqs.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/screens/openspace.dart';
import 'package:openspace_mobile_app/screens/terms_and_conditions.dart';
import 'package:openspace_mobile_app/utils/permission.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'screens/intro_slider_screen.dart';
import 'screens/map_screen.dart';
import 'screens/sign_in.dart';
import 'screens/report_screen.dart';
import 'screens/track_progress.dart';
import 'screens/profile.dart';
import 'screens/edit_profile.dart';
import 'screens/reported_issue.dart';
import 'screens/settings_page.dart';
import 'screens/language_choice.dart';
import 'screens/theme_change.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart GIS App',
            theme: AppTheme.lightTheme,
            darkTheme:AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const IntroSliderScreen(),
              '/home': (context) => const HomePage(),
              '/login': (context) => const SignInScreen(),
              '/register': (context) => const SignInScreen(),
              '/report-issue': (context) => const ReportIssuePage(),
              '/track-progress': (context) => const TrackProgressScreen(),
              '/user-profile': (context) => UserProfilePage(),
              '/edit-profile': (context) => EditProfilePage(),
              '/map': (context) => const MapScreen(),
              '/reported-issue': (context) => const ReportedIssuesPage(),
              '/setting': (context) => const SettingsPage(),
              '/language-change': (context) => const LanguageChangePage(),
              '/change-theme': (context) => const ThemeChangePage(),
              '/help-support': (context) =>  HelpPage(),
              '/terms': (context) => TermsAndConditionsPage(),
              '/open': (context) =>const  OpenSpacePage(),
            },
          );
        },
      ),
    );
  }
}
