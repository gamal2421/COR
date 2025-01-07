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
              final response = state.response;

              // استخدم الـ response مباشرة لتحويله إلى نص عادي
              String displayText = '';

              // مثال على كيفية تحويل الـ response إلى نص واضح
              if (response.containsKey('Full Name')) {
                displayText += 'Full Name: ${response['Full Name']}\n';
              }
              if (response.containsKey('Email address')) {
                displayText += 'Email: ${response['Email address']}\n';
              }
              if (response.containsKey('Phone number')) {
                displayText += 'Phone: ${response['Phone number']}\n';
              }
              if (response.containsKey('Education')) {
                displayText += 'Education:\n';
                final education = response['Education'];
                if (education is List) {
                  for (var edu in education) {
                    if (edu is Map) {
                      displayText += '  - ${edu['degree']} at ${edu['institution']}\n';
                    }
                  }
                }
              }

              // إضافة باقي البيانات بناءً على الـ response
              if (response.containsKey('Certifications')) {
                displayText += 'Certifications:\n';
                final certifications = response['Certifications'];
                if (certifications is List) {
                  for (var cert in certifications) {
                    displayText += '  - $cert\n';
                  }
                }
              }

              // عرض باقي البيانات بالطريقة نفسها
              if (response.containsKey('Projects')) {
                displayText += 'Projects:\n';
                final projects = response['Projects'];
                if (projects is List) {
                  for (var project in projects) {
                    displayText += '  - $project\n';
                  }
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: const Text("File Data", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        displayText, // عرض البيانات العادية
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
                                displayText,
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
                  ),
                ],
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
