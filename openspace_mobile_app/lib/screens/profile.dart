import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/edit_profile.dart';
import 'package:openspace_mobile_app/screens/pop_card.dart';
import 'package:openspace_mobile_app/screens/reported_issue.dart';
import 'package:openspace_mobile_app/screens/sign_in.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Ensure '/home' is defined in routes
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Profile Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Profile picture upload logic
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage('assets/images/avatar.jpg'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Your Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text('your.email@example.com', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 10),
                      const Text('(+255) 123-456-789', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Clickable Reports Card
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportedIssuesPage()));
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/report1.jpg',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('MY REPORTS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons with Animated Popup Calls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showPopup(
                          context,
                          title: "Logout Confirmation",
                          message: "Are you sure you want to log out?",
                          buttonText: "Logout",
                          icon: Icons.exit_to_app, // Fix: Using IconData
                          iconColor: Colors.red,
                          onConfirm: () {
                            // Navigate to SignInScreen after logout
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                                  (route) => false, // Removes previous screens
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Icon(Icons.exit_to_app, color: Colors.white, size: 24), // Button shows only icon
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to Show Animated Popup
  void _showPopup(
      BuildContext context, {
        required String title,
        required String message,
        required String buttonText,
        required IconData icon, // Fix: Using IconData
        required Color iconColor,
        required VoidCallback onConfirm,
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopupCard(
          title: title,
          message: message,
          buttonText: buttonText,
          icon: icon, // Fix: Correct parameter passing
          iconColor: iconColor,
          onConfirm: onConfirm,
        );
      },
    );
  }
}
