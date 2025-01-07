import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/services/file_upload_cubit.dart';

class FileUploadScreen extends StatelessWidget {
  const FileUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload and Analyze File'),
      ),
      body: BlocConsumer<FileUploadCubit, FileUploadState>(
        listener: (context, state) {
          if (state is FileUploadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FileUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File uploaded successfully!')),
            );
          }
        },
        builder: (context, state) {
          if (state is FileUploadLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FileUploadSuccess) {
            try {
              // تحويل الـ response (التي هي Map) إلى String باستخدام jsonEncode
              final String jsonResponse = jsonEncode(state.response);
              
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: 1, // التعداد واحد هنا لأنه سيكون لديك استجابة واحدة
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: const Text("File Data", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        jsonResponse, // عرض البيانات بتنسيق JSON
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // عرض التفاصيل الكاملة عند الضغط
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("File Data"),
                            content: SingleChildScrollView(
                              child: Text(
                                jsonResponse,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } catch (e) {
              return Center(
                child: Text(
                  'Error parsing data: ${e.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
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
              child: const Text('Select and Upload File'),
            ),
          );
        },
      ),
    );
  }
}
