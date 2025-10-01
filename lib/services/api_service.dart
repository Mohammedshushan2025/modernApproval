// مسار الملف: lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:modernapproval/models/form_report_model.dart';
import '../models/user_model.dart';


class ApiService {
  final String _baseUrl = "http://195.201.241.253:7001/ords/modern/Approval";

  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/all_emp'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((item) => UserModel.fromJson(item)).toList();
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

}
