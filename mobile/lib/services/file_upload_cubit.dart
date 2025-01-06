import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../API/api_service.dart';

part 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final ApiService apiService;

  FileUploadCubit(this.apiService) : super(FileUploadInitial());

  /// Method to handle file upload.
  Future<void> uploadFile(File file) async {
    if (!file.existsSync()) {
      emit(FileUploadError('The file does not exist.'));
      return;
    }

    emit(FileUploadLoading());

    try {
      // Call the uploadFile method from ApiService
      final response = await apiService.uploadFile(file);

      // Emit success state with the response (as String)
      emit(FileUploadSuccess(response));  // Emit String response
    } on HttpException catch (e) {
      emit(FileUploadError('HTTP Error: ${e.message}'));
    } on SocketException {
      emit(FileUploadError('No Internet connection.'));
    } catch (e) {
      emit(FileUploadError('Unexpected error occurred: $e'));
    }
  }
}
