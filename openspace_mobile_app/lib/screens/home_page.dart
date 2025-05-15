import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<_CardData> _cards = const [
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Report unusual activity', route: '/report'),
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Reported Issues', route: '/issues'),
    _CardData(iconPath: 'assets/images/track_progress.jpg', title: 'Track progress', route: '/track'),
    _CardData(iconPath: 'assets/images/openspace.jpg', title: 'Available open spaces', route: '/map'),
    _CardData(iconPath: 'assets/images/openspace_detail.jpg', title: 'Book Open Space', route: '/booking'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 3,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: const Text(
          'IOpen Space',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              itemBuilder: (context, index) => _buildCard(context, _cards[index]),
            );
          },
        ),
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
          width: 200, // Adjust width here
          height: 150, // Adjust height here
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
        )

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
