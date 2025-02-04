import 'package:flutter/material.dart';

class CVDetailPage extends StatelessWidget {
  final Map<String, dynamic> cv;
  const CVDetailPage({Key? key, required this.cv}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('CV Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    // Split the CV entries into two lists
    final entries = cv.entries.toList();
    final halfLength = (entries.length / 2).ceil();
    final firstColumnEntries = entries.sublist(0, halfLength);
    final secondColumnEntries = entries.sublist(halfLength);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: firstColumnEntries.map((entry) {
                  if (entry.key == "id") return const SizedBox(); // Skip ID field
                  return _buildDetailRow(entry.key, entry.value);
                }).toList(),
              ),
            ),
            const SizedBox(width: 16), // Add some spacing between columns
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: secondColumnEntries.map((entry) {
                  if (entry.key == "id") return const SizedBox(); // Skip ID field
                  return _buildDetailRow(entry.key, entry.value);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (value is List)
            ...value.map((item) => Text('• $item')).toList()
          else
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}