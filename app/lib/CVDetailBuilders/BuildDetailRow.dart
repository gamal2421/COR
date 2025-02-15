// lib/cv_detail_builders/build_detail_row.dart
import 'package:flutter/material.dart';
import 'BuildLabel.dart';
import 'BuildMapWidget.dart';
import 'BuildValueText.dart';
import 'BuildListItems.dart';

/// Builds a row for a single detail item.
Widget buildDetailRow(BuildContext context, String label, dynamic value) {
  if (value == null ||
      (value is String && value.contains("not provided")) ||
      (value is String && value.contains("dont have any Certifications"))) {
    return const SizedBox();
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        const SizedBox(height: 4),
        if (value is List)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: value.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: buildListItem(context, item),
              );
            }).toList(),
          )
        else if (value is Map)
          buildMapWidget(context, value)
        else
          buildValueText(context, value.toString()),
      ],
    ),
  );
}
