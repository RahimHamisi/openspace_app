import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class ThemeChangePage extends StatefulWidget {
  const ThemeChangePage({super.key});

  @override
  State<ThemeChangePage> createState() => _ThemeChangePageState();
}

class _ThemeChangePageState extends State<ThemeChangePage> {
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    _selectedTheme = isDark ? 'dark' : 'light';
  }

  void _changeTheme(String theme) {
    setState(() {
      _selectedTheme = theme;
    });

    Provider.of<ThemeProvider>(context, listen: false).setTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Theme",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppConstants.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppConstants.primaryBlue,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          color: AppConstants.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildThemeCard("Light Mode", "light"),
              const SizedBox(height: 20),
              _buildThemeCard("Dark Mode", "dark"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(String label, String code) {
    final bool isSelected = _selectedTheme == code;

    return GestureDetector(
      onTap: () => _changeTheme(code),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          color: AppConstants.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18)),
            Radio<String>(
              value: code,
              groupValue: _selectedTheme,
              activeColor: Colors.deepPurple,
              onChanged: (value) => _changeTheme(value!),
            ),
          ],
        ),
      ),
    );
  }
}
