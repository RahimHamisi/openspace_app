
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:openspace_mobile_app/api/graphql/graphql_service.dart';
import 'package:openspace_mobile_app/providers/locale_provider.dart';
import 'package:openspace_mobile_app/providers/theme_provider.dart';
import 'package:openspace_mobile_app/screens/Forget_password.dart';
import 'package:openspace_mobile_app/screens/Reset_Password.dart';
import 'package:openspace_mobile_app/screens/bookings.dart';
import 'package:openspace_mobile_app/screens/helps_and_Faqs.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/screens/terms_and_conditions.dart';
import 'package:openspace_mobile_app/screens/userreports.dart';
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
    await initHiveForFlutter(); // Required for GraphQL caching
    await requestNotificationPermission();
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      final client = GraphQLService().client;
      return MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        Provider<ValueNotifier<GraphQLClient>>(create: (_) => ValueNotifier(client)),
        ],
          child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return GraphQLProvider(
              client: ValueNotifier(client),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Smart GIS App',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
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
                '/map': (context) =>const MapScreen(),
                '/reported-issue': (context) => const ReportedIssuesPage(),
                '/setting': (context) => const SettingsPage(),
                '/language-change': (context) => const LanguageChangePage(),
                '/change-theme': (context) => const ThemeChangePage(),
                '/help-support': (context) => const HelpPage(),
                '/terms': (context) => const TermsAndConditionsPage(),
                  '/bookings-list': (context) => const MyBookingsPage(),
                  '/userReports': (context) => const UserReportsPage(),
                  '/forgot-password': (context) => const ForgotPasswordPage(),
                },
                onGenerateRoute: (RouteSettings settings) {
                  print("onGenerateRoute called with: ${settings.name}");
                  if (settings.name != null &&
                      settings.name!.startsWith('/reset-password')) {
                    final uri = Uri.parse(settings.name!);
                    if (uri.pathSegments.length == 3 &&
                        uri.pathSegments[0] == 'reset-password') {
                      final uid = uri.pathSegments[1];
                      final token = uri.pathSegments[2];
                      print(
                          "Extracted for ResetPasswordPage - uid: $uid, token: $token"); // For debugging
                      return MaterialPageRoute(
                        builder: (context) =>
                            ResetPasswordPage(uid: uid, token: token),
                      );
                    } else {
                      print(
                          "Route started with /reset-password but path segments did not match pattern."); // For debugging
                    }
                  }
                  print("Route ${settings.name} not found, showing default PageNotFound.");
                  return MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text("Error")),
                      body: const Center(child: Text("Page not found")),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }
}
