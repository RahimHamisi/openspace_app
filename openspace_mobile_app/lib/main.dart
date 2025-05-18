import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openspace_mobile_app/providers/locale_provider.dart';
import 'package:openspace_mobile_app/providers/theme_provider.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
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

void main() {
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
            darkTheme: AppTheme.lightTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/welcome-screen': (context) => const IntroSliderScreen(),
              '/': (context) => const HomePage(),
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
            },
          );
        },
      ),
    );
  }
}
