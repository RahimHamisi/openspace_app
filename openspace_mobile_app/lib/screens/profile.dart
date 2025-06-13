import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'package:openspace_mobile_app/screens/edit_profile.dart';
import 'package:openspace_mobile_app/screens/pop_card.dart';
import 'package:openspace_mobile_app/screens/reported_issue.dart';

import '../service/ProfileService.dart';
import 'bookings.dart';


class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ProfileService.fetchProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
      if (e.toString().contains('No authentication token')) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppConstants.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage())),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _profile?['photoUrl'] != null
                          ? NetworkImage(_profile!['photoUrl'])
                          : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile?['name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile?['email'] ?? 'No email',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 4),
                        Text('Verified', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'GENERAL',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryBlue),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              icon: Icons.settings,
              title: 'Profile Settings',
              subtitle: 'Update and modify your profile',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage())),
            ),
            _buildSettingsItem(
              context,
              icon: Icons.lock,
              title: 'Privacy',
              subtitle: 'Change your password',
              onTap: () {
                _showPopup(context, title: 'Privacy', message: 'Password change feature coming soon!', buttonText: 'OK', icon: Icons.lock, iconColor: Colors.blue, onConfirm: () => Navigator.pop(context));
              },
            ),
            _buildSettingsItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Change your notification settings',
              onTap: () {
                _showPopup(context, title: 'Notifications', message: 'Notification settings coming soon!', buttonText: 'OK', icon: Icons.notifications, iconColor: Colors.blue, onConfirm: () => Navigator.pop(context));
              },
            ),
            _buildSettingsItem(
              context,
              icon: Icons.report,
              title: 'My Reports',
              subtitle: 'View and manage your reports',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportedIssuesPage())),
            ),
            _buildSettingsItem(
              context,
              icon: Icons.event,
              title: 'My Bookings',
              subtitle: 'View and manage your bookings',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingsPage())),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppConstants.primaryBlue,
        currentIndex: 4,
        selectedItemColor: AppConstants.white,
        unselectedItemColor: AppConstants.white,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/expenses');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/add');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/wallet');
              break;
            case 4:
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
          child: Icon(icon, color: AppConstants.primaryBlue, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right, color: AppConstants.grey),
        onTap: onTap,
      ),
    );
  }

  void _showPopup(
      BuildContext context, {
        required String title,
        required String message,
        required String buttonText,
        required IconData icon,
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
          icon: icon,
          iconColor: iconColor,
          onConfirm: onConfirm,
        );
      },
    );
  }
}