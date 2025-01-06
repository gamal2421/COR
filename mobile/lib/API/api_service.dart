import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:frontend/API/api_exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

const String baseUrl = 'http://localhost:3000';

class ApiService {
  /// Method to get course recommendations.
  Future<String> courseRecommendation({
    required String query,
  }) async {
    log('course got request>>> $query');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course-recommendation'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'query': query,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        log('response.body: $decodedResponse');
        return decodedResponse.toString(); // Return as String (JSON formatted as text)
      } else {
        throw ApiException('Failed to perform search', statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on FormatException {
      throw ApiException('Failed to parse response');
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  /// Method to upload a file to the server.
  Future<String> uploadFile(File file) async {
    var uri = Uri.parse('$baseUrl/upload-cv');
    var request = http.MultipartRequest('POST', uri);

    log('File path: ${file.path}');
    String fileExtension = path.extension(file.path).toLowerCase();
    String mimeType;

    // Determine the MIME type based on file extension.
    switch (fileExtension) {
      case '.pdf':
        mimeType = 'application/pdf';
        break;
      case '.docx':
        mimeType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;
      case '.csv':
        mimeType = 'text/csv';
        break;
      default:
        mimeType = 'application/octet-stream';
    }

    // Add the file to the request.
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
        return respStr; // Return the response as string
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
