import 'dart:convert';

import 'package:corr/DataAdding/DataUploader.dart';
import 'package:corr/Else/SnackBar.dart';
import 'package:firedart/firestore/models.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:corr/Data retriving/getData.dart';

Future<void> runPythonScript(
    String filePath,
    Function setState,
    bool isUploading,
    BuildContext context,
    CollectionReference cvCollection) async {
  setState(() => isUploading = true);

  try {
    const pythonPath = 'python'; // Or 'python3'
    const scriptPath = 'assets/scripts/extract_text.py';

    int retryCount = 0;
    const maxRetries = 3;
    Map<String, dynamic>? jsonData;

    while (retryCount < maxRetries) {
      final result = await runExecutableArguments(
        pythonPath,
        [scriptPath, filePath],
      );

      if (result.exitCode == 0) {
        jsonData = jsonDecode(result.stdout.trim());
        if (jsonData != null && jsonData.isNotEmpty) {
          jsonData["isAssigned"] = "No";
          break;
        } else {
          retryCount++;
          showSnackbar("⚠ Retrying extraction... Attempt $retryCount",
              Colors.orange, context);
        }
      } else {
        showSnackbar(
            "❌ Error running script: ${result.stderr}", Colors.red, context);
        return;
      }
    }

    if (jsonData != null && jsonData.isNotEmpty) {
      await uploadDataToFirestore(jsonData, cvCollection, context);
      getData(setState, context);
    } else {
      showSnackbar("❌ Failed to extract valid data after $maxRetries attempts",
          Colors.red, context);
    }
  } catch (e) {
    showSnackbar("❌ Error: $e", Colors.red, context);
  } finally {
    setState(() => isUploading = false);
  }
}
