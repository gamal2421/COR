// lib/cv_detail_builders/build_list_item.dart
import 'package:flutter/material.dart';
import 'BuildMapWidget.dart';
import 'BuildValueText.dart';

/// Builds a list item widget for an individual detail.
Widget buildListItem(BuildContext context, dynamic item) {
  if (item is Map) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: buildMapWidget(context, item),
    );
  } else {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 16)),
        Expanded(child: buildValueText(context, item.toString())),
      ],
    );
  }
}
