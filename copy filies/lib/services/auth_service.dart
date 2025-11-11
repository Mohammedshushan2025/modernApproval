
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../utils/device_info_provider.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final DeviceInfoProvider _deviceInfoProvider = DeviceInfoProvider();
  static const String _userKey = 'loggedInUser';

  Future<UserModel> login(String userCode, String password) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('no_internet');
    }

    try {
      final List<UserModel> allUsers = await _apiService.getAllUsers();

      UserModel? user;
      try {
        print("🔍 Searching for userCode: $userCode");
        print("🔍 Available users: ${allUsers.map((u) => u.usersCode).toList()}");
        user = allUsers.firstWhere(
              (u) => u.usersCode.toString() == userCode,
        );
      } catch (e) {

        throw Exception('invalid_credentials');
      }

      if (user.password != password) {
        throw Exception('invalid_credentials');
      }

      await _saveUser(user);


      _postActivity(user.usersCode);

      return user;
    } catch (e) {

      if (e.toString().contains('invalid_credentials')) {
        rethrow;
      }

      print("A technical error occurred during login: $e");
      throw Exception('network_error');
    }
  }

  Future<void> _postActivity(int userCode) async {
    try {
      final ip = await _deviceInfoProvider.getIpAddress();
      final deviceId = await _deviceInfoProvider.getDeviceUniqueId();
      final osUser = await _deviceInfoProvider.getOsUser();
      final String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now().toUtc().add(Duration(hours: 1)));

      Position? position;
      try {
        position = await _deviceInfoProvider.determinePosition();
      } catch (e) {
        print("Could not get location for activity post: $e");
      }

      final Map<String, dynamic> loginData = {
        "users_code": userCode,
        "machine_ip": ip,
        "machine_mac": deviceId,
        "osuser": osUser,
        "contime": formattedDate,
        "latitude": position?.latitude,
        "longitude": position?.longitude,
      };

      print('data loginData $loginData');
      await _apiService.postLoginData(loginData);

    } catch (e) {
      print("Could not post activity data: $e");
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    return null;
  }
}