import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/services/file_upload_cubit.dart';


class FileUploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload and Analyze File'),
      ),
      body: BlocConsumer<FileUploadCubit, FileUploadState>(
        listener: (context, state) {
          if (state is FileUploadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FileUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File uploaded successfully!')),
            );
          }
        },
        builder: (context, state) {
          if (state is FileUploadLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FileUploadSuccess) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  state.response,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'docx', 'txt', 'csv'],
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  context.read<FileUploadCubit>().uploadFile(file);
                }
              },
              child: Text('Select and Upload File'),
            ),
          );
        },
      ),
    );
  }
}
