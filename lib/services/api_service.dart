// مسار الملف: lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:modernapproval/models/approval_status_response_model.dart'; // <-- إضافة
import 'package:modernapproval/models/form_report_model.dart';
import 'package:modernapproval/models/password_group_model.dart';
import 'package:modernapproval/models/purchase_request_model.dart';
import '../models/purchase_request_det_model.dart';
import '../models/purchase_request_mast_model.dart';
import '../models/user_model.dart';

class ApiService {
  // --- ✅ تم التعديل للرابط الجديد ---
  final String _baseUrl = "http://195.201.241.253:7001/ords/modern_test/Approval";

  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/all_emp'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      print("Data is $items");

      List<UserModel> users = [];
      for (var item in items) {
        try {
          users.add(UserModel.fromJson(item));
        } catch (e) {
          print("❌ Error parsing item: $item");
          print("❌ Error details: $e");
        }
      }

      print("users is $users");
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> postLoginData(Map<String, dynamic> loginData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ACCESSINFO'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );
      print('data loginData $loginData');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Failed to post login data. Status code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      } else {
        print('Response Body: ${response.body}');
        print('Login activity posted successfully!');
      }
    } catch (e) {
      print('Error posting login data: $e');
    }
  }

  Future<List<FormReportItem>> getFormsAndReports(int userId) async {
    final url = Uri.parse('$_baseUrl/get_form_reports_by_user/$userId');
    print('Fetching forms and reports from: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((item) => FormReportItem.fromJson(item)).toList();
      } else {
        print('Server Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('serverError');
      }
    } on SocketException {
      print('Network Error: No internet connection.');
      throw Exception('noInternet');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw Exception('noInternet');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('serverError');
    }
  }

  Future<List<PasswordGroup>> getUserPasswordGroups(int userId) async {
    final url = Uri.parse('$_baseUrl/get_user_password_group/$userId');
    print('Fetching password groups from: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isEmpty) return [];
        return items.map((item) => PasswordGroup.fromJson(item)).toList();
      } else {
        print('Server Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('serverError');
      }
    } on SocketException {
      print('Network Error: No internet connection.');
      throw Exception('noInternet');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw Exception('noInternet');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('serverError');
    }
  }

  Future<List<PurchaseRequest>> getPurchaseRequests({
    required int userId,
    required int roleId,
    required int passwordNumber,
  }) async {
    final queryParams = {
      'user_id': userId.toString(),
      'password_number': passwordNumber.toString(),
      'role_id': roleId.toString(),
    };
    final url = Uri.parse('$_baseUrl/GET_PUR_REQUEST_AUTH')
        .replace(queryParameters: queryParams);
    print('Fetching purchase requests from: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isEmpty) return [];
        return items.map((item) => PurchaseRequest.fromJson(item)).toList();
      } else {
        print('Server Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('serverError');
      }
    } on SocketException {
      print('Network Error: No internet connection.');
      throw Exception('noInternet');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw Exception('noInternet');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('serverError');
    }
  }

  Future<PurchaseRequestMaster> getPurchaseRequestMaster({
    required int trnsTypeCode,
    required int trnsSerial,
  }) async {
    final queryParams = {
      'trns_type_code': trnsTypeCode.toString(),
      'trns_serial': trnsSerial.toString(),
    };
    final url = Uri.parse('$_baseUrl/get_pur_request_mast')
        .replace(queryParameters: queryParams);
    print('Fetching purchase request master from: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isEmpty) {
          throw Exception('noData');
        }
        return PurchaseRequestMaster.fromJson(items.first);
      } else {
        print('Server Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('serverError');
      }
    } on SocketException {
      print('Network Error: No internet connection.');
      throw Exception('noInternet');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw Exception('noInternet');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('serverError');
    }
  }

  Future<List<PurchaseRequestDetail>> getPurchaseRequestDetail({
    required int trnsTypeCode,
    required int trnsSerial,
  }) async {
    final queryParams = {
      'trns_type_code': trnsTypeCode.toString(),
      'trns_serial': trnsSerial.toString(),
    };
    final url = Uri.parse('$_baseUrl/get_pur_request_det')
        .replace(queryParameters: queryParams);
    print('Fetching purchase request details from: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isEmpty) return [];
        return items.map((item) => PurchaseRequestDetail.fromJson(item)).toList();
      } else {
        print('Server Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('serverError');
      }
    } on SocketException {
      print('Network Error: No internet connection.');
      throw Exception('noInternet');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw Exception('noInternet');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('serverError');
    }
  }

  // --- ✅ --- بداية دوال عملية الاعتماد/الرفض --- ✅ ---

  // دالة مجمعة للتعامل مع الأخطاء
  Future<http.Response> _handleApiCall(
      Future<http.Response> Function() apiCall, String stageName, String? body) async {
    try {
      final response = await apiCall().timeout(const Duration(seconds: 30));
      print("✅ $stageName - Success - Status Code: ${response.statusCode}");
      // طباعة الجسم فقط لو مش GET
      if(body != null) {
        print("✅ $stageName - Sent Body: $body");
      }
      print("✅ $stageName - Response Body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw http.ClientException(
            "$stageName Error: Invalid response status code ${response.statusCode} | Body: ${response.body}",
            response.request?.url);
      }
      return response;
    } on SocketException {
      print("❌ $stageName - SocketException: No internet connection.");
      throw Exception('noInternet');
    } on TimeoutException {
      print("❌ $stageName - TimeoutException: Request timed out.");
      throw Exception('noInternet');
    } catch (e) {
      print("❌ $stageName - Unexpected Error: $e");
      // تمرير الخطأ الأصلي لمزيد من التفاصيل
      throw Exception('serverError: $e');
    }
  }

  // --- المرحلة الأولى: GET ---
  Future<ApprovalStatusResponse> stage1_getStatus({
    required int userId,
    required int roleCode,
    required String authPk1,
    required String authPk2,
    required int actualStatus,
  }) async {
    final queryParams = {
      'user_id': userId.toString(),
      'role_code': roleCode.toString(),
      'auth_pk1': authPk1,
      'auth_pk2': authPk2,
      'actual_status': actualStatus.toString(),
    };
    final url = Uri.parse('$_baseUrl/UPDATE_PUR_REQUEST_STATUS')
        .replace(queryParameters: queryParams);

    print("--- 🚀 Stage 1 (GET) ---");
    print("🚀 Calling: $url");

    final response = await _handleApiCall(
            () => http.get(url), "Stage 1 (GET)", null);

    final data = json.decode(response.body);
    if (data['items'] == null || (data['items'] as List).isEmpty) {
      print("❌ Stage 1 (GET) - Error: 'items' array is empty or null.");
      throw Exception('serverError: Empty response from Stage 1');
    }
    return ApprovalStatusResponse.fromJson(data['items'][0]);
  }

  // --- المرحلة الثالثة: PUT (Conditional) ---
  Future<void> stage3_checkLastLevel({
    required int userId,
    required String authPk1,
    required String authPk2,
  }) async {
    final url = Uri.parse('$_baseUrl/check_last_level_update');
    final bodyMap = {
      "user_id": userId,
      "auth_pk1": authPk1,
      "auth_pk2": authPk2,
    };
    final body = json.encode(bodyMap);
    final headers = {'Content-Type': 'application/json'};

    print("--- 🚀 Stage 3 (PUT) ---");
    print("🚀 Calling: $url");

    await _handleApiCall(
            () => http.put(url, headers: headers, body: body), "Stage 3 (PUT)", body);
  }

  // --- المرحلة الرابعة: PUT ---
  Future<void> stage4_updateStatus(Map<String, dynamic> bodyMap) async {
    final url = Uri.parse('$_baseUrl/UPDATE_PUR_REQUEST_STATUS');
    final body = json.encode(bodyMap);
    final headers = {'Content-Type': 'application/json'};

    print("--- 🚀 Stage 4 (PUT) ---");
    print("🚀 Calling: $url");

    await _handleApiCall(
            () => http.put(url, headers: headers, body: body), "Stage 4 (PUT)", body);
  }

  // --- المرحلة الخامسة: DELETE ---
  Future<void> stage5_deleteStatus(Map<String, dynamic> bodyMap) async {
    final url = Uri.parse('$_baseUrl/UPDATE_PUR_REQUEST_STATUS');
    final body = json.encode(bodyMap);
    final headers = {'Content-Type': 'application/json'};

    print("--- 🚀 Stage 5 (DELETE) ---");
    print("🚀 Calling: $url");

    await _handleApiCall(
            () => http.delete(url, headers: headers, body: body), "Stage 5 (DELETE)", body);
  }

  // --- المرحلة السادسة: POST (Conditional) ---
  Future<void> stage6_postFinalStatus(Map<String, dynamic> bodyMap) async {
    final url = Uri.parse('$_baseUrl/UPDATE_PUR_REQUEST_STATUS');
    final body = json.encode(bodyMap);
    final headers = {'Content-Type': 'application/json'};

    print("--- 🚀 Stage 6 (POST) ---");
    print("🚀 Calling: $url");

    await _handleApiCall(
            () => http.post(url, headers: headers, body: body), "Stage 6 (POST)", body);
  }
}