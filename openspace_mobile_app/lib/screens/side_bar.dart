import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final AnimationController controller;
  final VoidCallback onClose;

  const Sidebar({super.key, required this.controller, required this.onClose});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Starts off-screen
      end: Offset.zero, // Ends fully visible
    ).animate(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5, // Takes half the screen width
        height: MediaQuery.of(context).size.height, // Covers full screen height
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Open Space App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(),

            // Menu Items with Proper Spacing
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.person, 'My Profile', () {
                    Navigator.pushReplacementNamed(context, '/user-profile');

                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.notifications, 'Notifications', () {
                    Navigator.pushReplacementNamed(context, '/notification-screen');

                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.calendar_today, 'Events', () {
                    Navigator.pushReplacementNamed(context, '/upcoming-events');

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
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: widget.onClose,
                child: const Text('Close Menu', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
