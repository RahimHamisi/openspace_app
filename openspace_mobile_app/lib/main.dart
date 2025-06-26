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
import 'package:openspace_mobile_app/service/auth_service.dart';
import 'package:openspace_mobile_app/utils/permission.dart';
import 'package:provider/provider.dart';
import 'package:openspace_mobile_app/providers/user_provider.dart';
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
              onGenerateRoute: (RouteSettings settings) {
                print("onGenerateRoute called with: ${settings.name}");
                // Navigation guard for protected routes
                final protectedRoutes = [
                  '/user-profile',
                  '/edit-profile',
                  '/bookings-list',
                  '/userReports',
                ];
                if (protectedRoutes.contains(settings.name)) {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  if (userProvider.user.isAnonymous) {
                    return MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text("Access Denied")),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Please log in to access this feature."),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                                child: const Text("Log In"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }

                // Existing route handling
                if (settings.name != null && settings.name!.startsWith('/reset-password')) {
                  final uri = Uri.parse(settings.name!);
                  if (uri.pathSegments.length == 3 && uri.pathSegments[0] == 'reset-password') {
                    final uid = uri.pathSegments[1];
                    final token = uri.pathSegments[2];
                    print("Extracted for ResetPasswordPage - uid: $uid, token: $token");
                    return MaterialPageRoute(
                      builder: (context) => ResetPasswordPage(uid: uid, token: token),
                    );
                  }
                }

                final routes = {
                  '/': (context) => const IntroSliderScreen(),
                  '/home': (context) => const HomePage(),
                  '/login': (context) => const SignInScreen(),
                  '/register': (context) => const SignInScreen(),
                  '/report-issue': (context) => const ReportIssuePage(),
                  '/track-progress': (context) => const TrackProgressScreen(),
                  '/user-profile': (context) => const UserProfilePage(),
                  '/edit-profile': (context) => const EditProfilePage(),
                  '/map': (context) => const MapScreen(),
                  '/reported-issue': (context) => const ReportedIssuesPage(),
                  '/setting': (context) => const SettingsPage(),
                  '/change-theme': (context) => const ThemeChangePage(),
                  '/help-support': (context) => const HelpPage(),
                  '/terms': (context) => const TermsAndConditionsPage(),
                  '/bookings-list': (context) => const MyBookingsPage(),
                  '/userReports': (context) => const UserReportsPage(),
                  '/forgot-password': (context) => const ForgotPasswordPage(),
                };

                final routeBuilder = routes[settings.name];
                if (routeBuilder != null) {
                  return MaterialPageRoute(builder: routeBuilder);
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