import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'sign_up.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SIGN IN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('NAME'),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'User name'),
              ),
              const SizedBox(height: 16),
              const Text('PASSWORD'),
              const SizedBox(height: 8),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '********',
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (value) {}),
                  const Text('Remember me'),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MapScreen()),
                    );
                  },
                  child: const Text('LOGIN'),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('OR')),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Don’t have an account? Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
