import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'api_exceptions.dart';  // تأكد من أنك أضفت الاستيراد الصحيح

const String baseUrl = 'http://127.0.0.1:5000'; // Flask API URL

class ApiService {
  /// Method to upload a file to the Flask server.
  Future<Map<String, dynamic>> uploadFile(File file) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);

    log('File path: ${file.path}');
    String fileExtension = path.extension(file.path).toLowerCase();
    String mimeType;

    // تحديد الـ MIME type بناءً على امتداد الملف
    switch (fileExtension) {
      case '.pdf':
        mimeType = 'application/pdf';
        break;
      case '.docx':
        mimeType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;
      case '.txt':
        mimeType = 'text/plain';
        break;
      default:
        mimeType = 'application/octet-stream';
    }

    // إضافة الملف إلى الطلب
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(mimeType),
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        log('Upload successful: $respStr');
        return jsonDecode(respStr); // تحويل الاستجابة إلى خريطة JSON
      } else {
        throw ApiException('File upload failed. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('No Internet connection');
    } catch (e) {
      throw ApiException('Unexpected error occurred during file upload: $e');
    }
  }
}
