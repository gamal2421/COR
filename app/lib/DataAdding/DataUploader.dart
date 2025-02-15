
 import 'package:corr/Else/SnackBar.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';

Future<void> uploadDataToFirestore
 (Map<String, dynamic> data,
 CollectionReference cvCollection,
 BuildContext context) async {
    try {
      final document = await cvCollection.add(data);
      showSnackbar("✅ Data uploaded to Firestore: ${document.id}", Colors.green,
          context);
     
    } catch (e) {
      showSnackbar("❌ Error uploading data: $e", Colors.red, context);
    }
  }
