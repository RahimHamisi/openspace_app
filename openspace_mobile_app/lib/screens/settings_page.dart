import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/language_choice.dart';
import 'package:openspace_mobile_app/screens/reported_issue.dart';
import 'package:openspace_mobile_app/screens/theme_change.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,// Removed dynamic translation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: AppConstants.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppConstants.primaryBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildListTile(Icons.language, "Change Language", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageChangePage()));
          }),
          _buildListTile(Icons.light_mode, "Theme", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeChangePage()));
          }),
          _buildListTile(Icons.notifications, "Notification Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportedIssuesPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryBlue),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
