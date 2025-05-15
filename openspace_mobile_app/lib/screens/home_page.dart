import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<_CardData> _cards = const [
    _CardData(
      iconPath: 'assets/images/report1.png',
      title: 'Report unusual activity in a given open space',
      route: '/report',
    ),
    _CardData(
      iconPath: 'assets/images/report1.png',
      title: 'Reported Issues',
      route: '/issues',
    ),
    _CardData(
      iconPath: 'assets/images/track_progress.png',
      title: 'Track progress of your submitted report',
      route: '/track',
    ),
    _CardData(
      iconPath: 'assets/images/openspace_detail.jpg',
      title: 'See available open spaces with their corresponding facilities',
      route: '/map',
    ),
    _CardData(
      iconPath: 'assets/images/openspace.jpg',
      title: 'Book Open Space',
      route: '/booking',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        elevation: 3,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
            const Spacer(),
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
          ],
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildCard(context, _cards[index]),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _CardData card) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, card.route),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive image on top
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                card.iconPath,
                height: 180,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                card.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final String iconPath;
  final String title;
  final String route;

  const _CardData({
    required this.iconPath,
    required this.title,
    required this.route,
  });
}
