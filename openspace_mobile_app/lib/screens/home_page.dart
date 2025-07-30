import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/side_bar.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'package:openspace_mobile_app/widget/custom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _CardData {
  final String iconPath;
  final String title;
  final String route;
  const _CardData({required this.iconPath, required this.title, required this.route});
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = false;
  int _currentIndex = 0;
  int _carouselIndex = 0;
  double _spacerHeight = 20.0;
  final PageController _pageController = PageController();
  int _notificationCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoScrollTimer;

  final List<_CardData> _cards = const [
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Report Unusual Activity', route: '/map'),
    _CardData(iconPath: 'assets/images/report1.jpg', title: 'Reported Issues', route: '/reported-issue'),
    _CardData(iconPath: 'assets/images/track_progress.jpg', title: 'Track Progress', route: '/track-progress'),
    _CardData(iconPath: 'assets/images/openspace_detail.jpg', title: 'Book Open Space', route: '/map'),
  ];

  final List<String> _horizontalImages = [
    'assets/images/green_space.jpg',
    'assets/images/green_space2.jpg',
    'assets/images/green_space.jpg',
    'assets/images/green_space2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _spacerHeight = 40.0);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _notificationCount = 1);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _notificationCount = 0);
    });

    // Auto scroll for carousel
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted) {
        int next = (_pageController.page?.round() ?? 0) + 1;
        if (next >= _horizontalImages.length) next = 0;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const Sidebar(),
      body: CustomScrollView(
        slivers: [
          _buildEnhancedAppBar(screenWidth, screenHeight),
          SliverToBoxAdapter(child: AnimatedContainer(height: _spacerHeight, duration: const Duration(milliseconds: 500))),
          _buildWelcomeSection(),
          _buildSectionTitle('Quick Actions'),
          _buildActionCards(),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildEnhancedAppBar(double screenWidth, double screenHeight) {
    return SliverAppBar(
      backgroundColor: AppConstants.primaryBlue,
      expandedHeight: screenHeight * 0.45, // Matches the reference image's height proportion
      pinned: true,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 24), // Menu icon for drawer
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'OpenSpace',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
              onPressed: () => setState(() => _notificationCount = 0),
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_notificationCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryBlue,
                AppConstants.primaryBlue.withOpacity(0.8),
                AppConstants.primaryBlue.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Image Carousel with adjusted height
              Positioned.fill(
                top: 100, // Adjusted to match the reference image's layout
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _horizontalImages.length,
                      onPageChanged: (index) => setState(() => _carouselIndex = index),
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _horizontalImages[index],
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dar es Salaam Open Spaces',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Building stronger communities together',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_horizontalImages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _carouselIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _carouselIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.park,
                      color: AppConstants.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome to OpenSpace!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dar es Salaam',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your community hub for managing open spaces. Report issues, track progress, and book spaces with ease. Together, we\'re building a better Dar es Salaam.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA19999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(), // Add explicit scroll physics
          itemCount: _cards.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final card = _cards[index];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, card.route),
              child: Container(
                width: 160, // Fixed width for each card
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryBlue.withOpacity(0.1), // Fixed gradient issue
                      AppConstants.primaryBlue.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          card.iconPath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        card.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}