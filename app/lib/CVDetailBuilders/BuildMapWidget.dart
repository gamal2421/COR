// lib/cv_detail_builders/build_map_widget.dart
import 'package:flutter/material.dart';

/// Builds a widget for displaying a map of values.
Widget buildMapWidget(BuildContext context, Map map) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: map.entries.map<Widget>((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16)),
            Flexible(
              fit: FlexFit.loose,
              child: Wrap(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
