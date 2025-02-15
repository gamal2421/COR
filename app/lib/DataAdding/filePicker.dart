import 'dart:io';

import 'package:corr/Else/SnackBar.dart';
import 'package:corr/Else/Variables.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> pickFiles(BuildContext context, Function func,
    List<File> selectedFiles, Function runPythonScript) async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    showSnackbar("⚠ Permission denied!", Colors.orange, context);
    return;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'docx', 'txt'],
    allowMultiple: true,
  );

  if (result != null && result.files.isNotEmpty) {
    func(() {
      selectedFiles = result.files.map((file) => File(file.path!)).toList();
    });

    for (var file in selectedFiles) {
      await runPythonScript(
          file.path, func, isUploading, context, cvCollection);
    }
  }
}
