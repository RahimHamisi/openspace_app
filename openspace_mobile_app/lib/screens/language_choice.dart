import 'package:flutter/material.dart';

import '../utils/constants.dart';

class LanguageChangePage extends StatefulWidget {
  const LanguageChangePage({super.key});

  @override
  State<LanguageChangePage> createState() => _LanguageChangePageState();
}

class _LanguageChangePageState extends State<LanguageChangePage> {
  String _selectedLanguage = 'en';

  void _changeLanguage(String code) {
    setState(() {
      _selectedLanguage = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Language",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: AppConstants.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: AppConstants.white),
          color: AppConstants.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppConstants.primaryBlue,
      ),
      backgroundColor: const Color(0xFF8B7B78), // Muted background
      body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row with Back Arrow and Title

                const SizedBox(height: 32),
                _buildLanguageCard("English", "en"),

                const SizedBox(height: 32),
                _buildLanguageCard("Swahili", "sw"),

              ],
            ),
          ),
      ),
    );
  }

  Widget _buildLanguageCard(String label, String code) {
    final bool isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: Container(
        height:100,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          color: AppConstants.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            Radio<String>(
              value: code,
              groupValue: _selectedLanguage,
              activeColor: Colors.deepPurple,
              onChanged: (value) => _changeLanguage(value!),
            ),
          ],
        ),
      ),
    );
  }
}
