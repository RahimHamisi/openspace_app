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
  late AnimationController _controller;
  bool _isSidebarOpen = false;

  final List<_CardData> _cards = const [
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Report unusual activity', route: '/report-issue'),
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Reported Issues', route: '/reported-issue'),
    _CardData(iconPath: 'assets/images/track_progress.jpg', title: 'Track progress', route: '/track-progress'),
    _CardData(iconPath: 'assets/images/openspace.jpg', title: 'Available open spaces', route: '/open'),
    _CardData(iconPath: 'assets/images/openspace_detail.jpg', title: 'Book Open Space', route: '/booking'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      _isSidebarOpen ? _controller.forward() : _controller.reverse();
    });
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppConstants.white, size: 30),
          onPressed: _toggleSidebar,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppConstants.white , size: 30),
            onPressed: () {},
          ),
        ],
      ),
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
          if (_isSidebarOpen)
            Sidebar(controller: _controller, onClose: _toggleSidebar), // Sidebar now full height & half width
        ],
      ),
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
