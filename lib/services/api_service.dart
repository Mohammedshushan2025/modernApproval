// مسار الملف: lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:modernapproval/models/form_report_model.dart';
import 'package:modernapproval/models/password_group_model.dart';
import 'package:modernapproval/models/purchase_request_model.dart';
import '../models/purchase_request_det_model.dart';
import '../models/purchase_request_mast_model.dart';
import '../models/user_model.dart';


class ApiService {
  final String _baseUrl = "http://195.201.241.253:7001/ords/modern/Approval";

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
        Uri.parse('$_baseUrl/ACCESSINFO'), // <-- تأكد من صحة هذا الرابط
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );
      print('data loginData $loginData');
      // الخادم يرد بـ 201 عند الإنشاء الناجح عادةً
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Failed to post login data. Status: ${response.statusCode}');
        // طباعة الخطأ الذي أرسلته لي
        print('Response Body: ${response.body}');
      } else {
        print('Response Body: ${response.body}');
        print('Login activity posted successfully!');
      }
    } catch (e) {
      print('Error posting login data: $e');
    }
  }


  // ==== ✅ دالة جديدة لجلب الموافقات والتقارير ====
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
        // خطأ من الخادم
        print('Server Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('serverError'); // مفتاح للترجمة
      }
    } on SocketException {
      // خطأ في الشبكة
      print('Network Error: No internet connection.');
      throw Exception('noInternet'); // مفتاح للترجمة
    } on TimeoutException {
      // خطأ انتهاء الوقت
      print('Network Error: Request timed out.');
      throw Exception('noInternet');
    } catch (e) {
      // أي خطأ آخر
      print('An unexpected error occurred: $e');
      throw Exception('serverError');
    }
  }

// ==== ✅ دالة جديدة لجلب مجموعات كلمات المرور (الفروع) ====
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

  // ==== ✅ دالة جديدة لجلب طلبات الشراء ====
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
    final url = Uri.parse('$_baseUrl/GET_PUR_REQUEST_AUTH').replace(queryParameters: queryParams);
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

// ==== ✅ دالة جديدة لجلب بيانات الطلب الرئيسية ====
  Future<PurchaseRequestMaster> getPurchaseRequestMaster({
    required int trnsTypeCode,
    required int trnsSerial,
  }) async {
    final queryParams = {
      'trns_type_code': trnsTypeCode.toString(),
      'trns_serial': trnsSerial.toString(),
    };
    final url = Uri.parse('$_baseUrl/get_pur_request_mast').replace(queryParameters: queryParams);
    print('Fetching purchase request master from: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isEmpty) {
          throw Exception('noData'); // لا يوجد طلب بهذا الرقم
        }
        // نفترض أنه يرجع دائماً عنصراً واحداً
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

  // ==== ✅ دالة جديدة لجلب تفاصيل أصناف الطلب ====
  Future<List<PurchaseRequestDetail>> getPurchaseRequestDetail({
    required int trnsTypeCode,
    required int trnsSerial,
  }) async {
    final queryParams = {
      'trns_type_code': trnsTypeCode.toString(),
      'trns_serial': trnsSerial.toString(),
    };
    final url = Uri.parse('$_baseUrl/get_pur_request_det').replace(queryParameters: queryParams);
    print('Fetching purchase request details from: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isEmpty) return []; // قد لا يكون هناك أصناف
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
}

