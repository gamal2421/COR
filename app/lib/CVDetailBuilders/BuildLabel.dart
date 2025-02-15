// lib/cv_detail_builders/build_label.dart
import 'package:flutter/material.dart';

/// Builds a label widget with style based on the label name.
Widget buildLabel(String label) {
  TextStyle headerStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  TextStyle subHeaderStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );
  TextStyle fieldLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.red[800]!,
  );

  String lowerLabel = label.toLowerCase();
  if (lowerLabel.contains("header") && !lowerLabel.contains("sub")) {
    return Text(label, style: headerStyle);
  } else if (lowerLabel.contains("subheader") || lowerLabel.contains("sub")) {
    return Text(label, style: subHeaderStyle);
  } else {
    return Text('$label:', style: fieldLabelStyle);
  }
}
