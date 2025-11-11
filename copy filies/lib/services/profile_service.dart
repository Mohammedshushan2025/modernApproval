import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String _baseUrl = 'http://49.12.83.111:7001/ords/ascon_scai/hrapi';
  static const Duration _timeout = Duration(seconds: 30);


  Future<Map<String, dynamic>?> getProfileData(int userCode) async {
    try {
      print('🔄 ProfileService: Fetching profile data for user $userCode');

      final response = await http.get(
        Uri.parse('$_baseUrl/emp_info/$userCode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      print('📡 ProfileService: Response status ${response.statusCode}');
      print('📡 ProfileService: Response body ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          print('✅ ProfileService: Profile data retrieved successfully');
          return data['items'][0];
        } else {
          print('⚠️ ProfileService: No profile data found');
          throw Exception('No profile data found');
        }
      } else {
        print('❌ ProfileService: Failed with status ${response.statusCode}');
        throw Exception('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ProfileService: Exception occurred: $e');
      rethrow;
    }
  }


  Future<bool> uploadProfileImage(int userCode, String base64Image) async {
    try {
      print('🔄 ProfileService: Uploading image for user $userCode');

      final requestData = {
        'emp_id': userCode,
        'photo': base64Image,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/emp_photo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      ).timeout(_timeout);

      print('📡 ProfileService: Upload response status ${response.statusCode}');
      print('📡 ProfileService: Upload response body ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ ProfileService: Image uploaded successfully');
        return true;
      } else {
        print('❌ ProfileService: Upload failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ ProfileService: Upload exception: $e');
      return false;
    }
  }


  String getProfileImageUrl(int userCode, {bool forceRefresh = false}) {
    String url = '$_baseUrl/emp_photo/$userCode';
    if (forceRefresh) {
      url += '?t=${DateTime.now().millisecondsSinceEpoch}';
    }
    return url;
  }


  Future<bool> checkServiceConnection(int userCode) async {
    try {
      print('🔄 ProfileService: Testing connection...');

      final response = await http.get(
        Uri.parse('$_baseUrl/emp_info/$userCode'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      bool isConnected = response.statusCode == 200;
      print(isConnected
          ? '✅ ProfileService: Connection test successful'
          : '❌ ProfileService: Connection test failed');

      return isConnected;
    } catch (e) {
      print('❌ ProfileService: Connection test exception: $e');
      return false;
    }
  }
}