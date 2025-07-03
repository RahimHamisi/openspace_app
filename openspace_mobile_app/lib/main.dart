import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:openspace_mobile_app/api/graphql/graphql_service.dart';
import 'package:openspace_mobile_app/providers/locale_provider.dart';
import 'package:openspace_mobile_app/providers/theme_provider.dart';
import 'package:openspace_mobile_app/screens/Forget_password.dart';
import 'package:openspace_mobile_app/screens/Reset_Password.dart';
import 'package:openspace_mobile_app/screens/book_openspace.dart';
import 'package:openspace_mobile_app/screens/bookings.dart';
import 'package:openspace_mobile_app/screens/helps_and_Faqs.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/screens/terms_and_conditions.dart';
import 'package:openspace_mobile_app/screens/userreports.dart';
import 'package:openspace_mobile_app/service/auth_service.dart';
import 'package:openspace_mobile_app/utils/alert/access_denied_dialog.dart';
import 'package:openspace_mobile_app/utils/alert/error_dialog.dart';
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
                final protectedRoutes = [
                  '/user-profile',
                  '/edit-profile',
                  '/bookings-list',
                  '/userReports',
                ];
                if (protectedRoutes.contains(settings.name)) {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  if (userProvider.user.isAnonymous) {
                    showAccessDeniedDialog(context, featureName: settings.name!.split('/').last);
                  }
                  else  {
                    Navigator.pushNamed(context, settings.name!);
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
                // Handle booking page with spaceId and optional spaceName
                if (settings.name != null && settings.name!.startsWith('/book')) {
                  final uri = Uri.parse(settings.name!);
                  int? spaceId;
                  String? spaceName;

                  // Extract spaceId from the route path (e.g., /book/123)
                  if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'book') {
                    try {
                      spaceId = int.parse(uri.pathSegments[1]); // Convert string to int
                    } catch (e) {
                      print("Invalid spaceId format: ${uri.pathSegments[1]}");
                    }
                  }

                  // Extract spaceId and spaceName from arguments if provided
                  if (settings.arguments != null) {
                    if (settings.arguments is int) {
                      spaceId = settings.arguments as int;
                    } else if (settings.arguments is Map) {
                      final args = settings.arguments as Map;
                      spaceId = args['spaceId'] is int ? args['spaceId'] : int.tryParse(args['spaceId'].toString());
                      spaceName = args['spaceName']?.toString();
                    }
                  }

                  if (spaceId != null) {
                    return MaterialPageRoute(
                      builder: (context) => BookingPage(
                        spaceId: spaceId!,
                        spaceName: spaceName,
                      ),
                    );
                  } else {
                    return MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text("Error")),
                        body: const Center(child: Text("Invalid or missing spaceId")),
                      ),
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
                showErrorDialog(context, routeName: settings.name ?? "unknown");
                return null;
              },
            ),
          );
        },
      ),
    );
  }
}