import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';

Future<void> fetchArchivedCVs(
  Function setState,
  Function(List<Map<String, dynamic>>) updateData,
  bool isLoading,
  BuildContext context,
) async {
  setState(() {
    isLoading = true;
  });
  try {
    final querySnapshot = await Firestore.instance.collection('Archive').get();
    setState(() {
      updateData(querySnapshot.map((doc) {
        final data = doc.map;
        return {"id": doc.id, ...data};
      }).toList());
      isLoading = false;
    });
  } catch (e) {
    print("Error fetching archived CVs: $e");
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load archived CVs: $e')),
    );
  }
}
