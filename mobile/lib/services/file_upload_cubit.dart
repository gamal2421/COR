import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:frontend/API/api_service.dart';
import 'package:meta/meta.dart';

part 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final ApiService apiService;

  FileUploadCubit(this.apiService) : super(FileUploadInitial());

  Future<void> uploadFile(File file) async {
    emit(FileUploadLoading());
    try {
      final Map<String, dynamic> response = await apiService.uploadFile(file);
      emit(FileUploadSuccess(response)); // إرسال الـ Map بشكل صحيح
    } catch (e) {
      emit(FileUploadError('Failed to upload file: $e'));
    }
  }
}
