import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'map_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SIGN UP'),
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
              const Text('EMAIL'),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'user@gmail.com'),
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
                  const Text('I agree with Terms and Privacy'),
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
                  child: const Text('SIGN UP'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                    );
                  },
                  child: const Text('Already have an account? Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
