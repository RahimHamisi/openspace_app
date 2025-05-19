import 'package:flutter/material.dart';

class OpenSpacePage extends StatefulWidget {
  const OpenSpacePage({super.key});

  @override
  _OpenSpacePageState createState() => _OpenSpacePageState();
}

class _OpenSpacePageState extends State<OpenSpacePage> {
  final List<Map<String, String>> openSpaces = [
    {"name": "Green Park", "location": "Downtown"},
    {"name": "Central Plaza", "location": "City Center"},
    {"name": "Ocean View Space", "location": "Coastal Area"},
    {"name": "Sunset Pavilion", "location": "West Side"},
    {"name": "Urban Garden", "location": "Suburban Area"},
    {"name": "Eco Square", "location": "Eco District"},
    {"name": "Riverfront Space", "location": "Near River"},
    {"name": "Skyline Park", "location": "Business District"},
    {"name": "Community Field", "location": "Residential Zone"},
    {"name": "Nature Retreat", "location": "Outskirts"},
  ];

  void _showOptions(BuildContext context, String spaceName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white, // Removed gradient effect
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Options for $spaceName",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 1),
                _optionButton("View Details"),
                _optionButton("Get Directions"),
                _optionButton("Report Issue"),
                _optionButton("Share Location"),
                _optionButton("Save to Favorites"),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextButton(
        onPressed: () => Navigator.pop(context, title),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Available Open Spaces"),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: openSpaces.length,
                itemBuilder: (context, index) {
                  return _buildOpenSpaceCard(openSpaces[index]);
                },
              );
            } else {
              return ListView.builder(
                itemCount: openSpaces.length,
                itemBuilder: (context, index) {
                  return _buildOpenSpaceCard(openSpaces[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildOpenSpaceCard(Map<String, String> space) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space["name"]!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  space["location"]!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black54, size: 30),
              onPressed: () => _showOptions(context, space["name"]!),
            ),
          ],
        ),
      ),
    );
  }
}
