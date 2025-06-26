import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../utils/constants.dart';
import '../model/user_model.dart';
import '../providers/user_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAlert(QuickAlertType type, String message, {VoidCallback? onConfirmed}) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: type,
      text: message,
      showConfirmBtn: true,
      confirmBtnText: 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onConfirmed != null) {
          onConfirmed();
        }
      },
    );
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response != null && response['success'] == true) {
        // Set user in UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(User.fromLoginJson(response));

        _showAlert(
          QuickAlertType.success,
          response['message'] ?? "Successfully Logged In!",
          onConfirmed: () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        );
      } else {
        _showAlert(
          QuickAlertType.error,
          response?['message'] ?? "Login failed. Please check your credentials.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (kDebugMode) {
        print('SignInScreen: Login error - $errorMessage');
      }
      _showAlert(
        QuickAlertType.error,
        errorMessage.contains('timeout')
            ? 'Connection timed out. Please check your internet and try again.'
            : 'Login failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/bibi.png', height: 75),
                            const SizedBox(height: 16),
                            const Text(
                              'Welcome back',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please enter your credentials to sign in',
                              style: TextStyle(fontSize: 16, color: AppConstants.grey),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Username is required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: '********',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter your password' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                    ),
                                    const Text('Remember me'),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/forgot-password');
                                  },
                                  child: const Text('Forgot password?', style: TextStyle(color: Colors.purple)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(color: AppConstants.white, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                "Don't have an account? Create account",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}