import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/network_caller/endpoints.dart';

class UploadService extends GetxController {
  Future<String?> uploadFile(File file, String token) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        print("UploadService: File does not exist: ${file.path}");
        throw Exception("Selected file does not exist");
      }

      final uri = Uri.parse('${Urls.baseUrl}/chats/upload-images');
      print("UploadService: Uploading to $uri");
      print("UploadService: File path: ${file.path}");
      print("UploadService: File size: ${await file.length()} bytes");

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = token
        ..files.add(await http.MultipartFile.fromPath('images', file.path));

      print("UploadService: Sending request with token: ${token.substring(0, 20)}...");
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print("UploadService: Upload request timed out");
          throw TimeoutException("Upload request timed out");
        },
      );
      
      final respBody = await response.stream.bytesToString();
      print("UploadService: Response -> $respBody (status: ${response.statusCode})");

      if (response.statusCode == 200) {
        final json = jsonDecode(respBody);
        print("UploadService: Parsed response -> $json");
        
        if (json['success'] == true && json['data'] is List && json['data'].isNotEmpty) {
          final imageUrl = json['data'][0];
          if (imageUrl is String && imageUrl.isNotEmpty) {
            print("UploadService: Successfully uploaded image: $imageUrl");
            return imageUrl;
          }
          throw Exception("Invalid image URL format: ${json['data']}");
        }
        throw Exception("Invalid response data: ${json['data']}");
      } else {
        final json = jsonDecode(respBody);
        print("UploadService: Error response -> $json");
        
        if (json['err']?['name'] == 'JsonWebTokenError') {
          throw Exception("Authentication failed - please log in again");
        }
        throw Exception("Upload failed: ${json['message'] ?? 'Status ${response.statusCode}'}");
      }
    } catch (e) {
      print("UploadService: Error -> $e");
      // Don't show snackbar here as it will be handled by ChatController
      rethrow;
    }
  }
}
