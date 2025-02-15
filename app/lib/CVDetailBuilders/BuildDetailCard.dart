// lib/cv_detail_builders/build_detail_card.dart
import 'package:flutter/material.dart';
import 'BuildDetailRow.dart';

/// Splits the CV details into two columns and builds a detail card.
Widget buildDetailCard(BuildContext context, Map<String, dynamic> cv) {
  final sortedEntries = cv.entries.toList()
    ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

  final halfLength = (sortedEntries.length / 2).ceil();
  final firstColumnEntries = sortedEntries.sublist(0, halfLength);
  final secondColumnEntries = sortedEntries.sublist(halfLength);

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: firstColumnEntries.map((entry) {
                if (entry.key == "id") return const SizedBox();
                return buildDetailRow(context, entry.key, entry.value);
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: secondColumnEntries.map((entry) {
                if (entry.key == "id") return const SizedBox();
                return buildDetailRow(context, entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
