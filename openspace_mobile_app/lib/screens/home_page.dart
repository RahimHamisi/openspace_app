import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/side_bar.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
// import 'package:openspace_mobile_app/screens/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = false;
  int _selectedIndex = 0;


  final List<_CardData> _cards = const [
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Report unusual activity', route: '/map'),
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Reported Issues', route: '/reported-issue'),
    _CardData(iconPath: 'assets/images/track_progress.jpg', title: 'Track progress', route: '/track-progress'),
    _CardData(iconPath: 'assets/images/openspace.jpg', title: 'Available open spaces', route: '/open'),
    _CardData(iconPath: 'assets/images/openspace_detail.jpg', title: 'Book Open Space', route: '/map'),
  ];

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlue,
        elevation: 3,
        toolbarHeight: 150,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text(
          'Open Space',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppConstants.white),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppConstants.white, size: 30),
              onPressed:Scaffold.of(context).openDrawer
            );
          }
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppConstants.white , size: 30),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) => _buildCard(context, _cards[index]),
                );
              },
            ),
          ),
           // Sidebar now full height & half width
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.blue,
      currentIndex: _selectedIndex, // Track this in your state
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      onTap: (index) {
        if (index == _selectedIndex) return; // Already on this page

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/map');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/user-profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
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


  Widget _buildCard(BuildContext context, _CardData card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, card.route),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 200,
          height: 150,
          child: Card(
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(card.iconPath, width: 60, height: 60),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(card.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final String iconPath;
  final String title;
  final String route;
  const _CardData({required this.iconPath, required this.title, required this.route});
}
