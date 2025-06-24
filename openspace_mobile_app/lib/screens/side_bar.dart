import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(  // Ensure it's wrapped in Drawer
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
        height: MediaQuery.of(context).size.height, // Full height
        decoration: const BoxDecoration(
          color: AppConstants.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Open Space App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(
              height: 100,
            ),

            // Sidebar Items
            Expanded(

              child: ListView(
                padding: EdgeInsets.only(top: 20),
                children: [
                  _buildMenuItem(Icons.person, 'My Profile', () {
                    Navigator.pushReplacementNamed(context, '/user-profile');
                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.contact_mail, 'Helps and FAQs', () {
                    Navigator.pushReplacementNamed(context, '/help-support');
                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.settings, 'Settings', () {
                    Navigator.pushReplacementNamed(context, '/setting');
                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.help_outline, 'Terms and Condition', () {
                    Navigator.pushReplacementNamed(context, '/terms');
                 }),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.exit_to_app, 'Sign Out', () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                ],
              ),
            ),

            // Close Button
          ],
        ),
      ),
    );
  }

  // Function to build menu items dynamically
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
