import 'package:flutter/material.dart';

class ReportTypeSection extends StatelessWidget {
  final String? selectedReportType;
  final Function(String) onSelected;

  const ReportTypeSection({super.key, required this.selectedReportType, required this.onSelected});

  static final List<Map<String, dynamic>> reportTypes = [
    {'type': 'Domestic Rubbish', 'icon': Icons.delete_outline},
    {'type': 'Graffiti or Vandalism', 'icon': Icons.brush},
    {'type': 'Pollution Hazard', 'icon': Icons.warning_amber_rounded},
    {'type': 'Traffic Hazard', 'icon': Icons.traffic},
    {'type': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What are you reporting?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: reportTypes.map((report) {
                final bool isSelected = selectedReportType == report['type'];
                return GestureDetector(
                  onTap: () => onSelected(report['type']),
                  child: Container(
                    width: MediaQuery.of(context).size.width ,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(report['icon'], color: isSelected ? Colors.blue : Colors.grey.shade700, size: 28),
                        const SizedBox(height: 8),
                        Text(report['type'], textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.blue : Colors.black87)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
