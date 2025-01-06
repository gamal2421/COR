part of 'file_upload_cubit.dart';

@immutable
abstract class FileUploadState {}

class FileUploadInitial extends FileUploadState {}

class FileUploadLoading extends FileUploadState {}

class FileUploadSuccess extends FileUploadState {
  final Map<String, dynamic> response;

  FileUploadSuccess(this.response);
}

class FileUploadError extends FileUploadState {
  final String message;

  FileUploadError(this.message);
}
