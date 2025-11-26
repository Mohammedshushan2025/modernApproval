import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class DeviceInfoProvider {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final NetworkInfo _networkInfo = NetworkInfo();
  final Uuid _uuid = const Uuid();

  Future<String?> getIpAddress() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      print('Could not get IP Address: $e');
      return 'Unknown IP';
    }
  }

  Future<String?> getOsUser() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.name;
      }
    } catch (e) {
      print('Could not get OS User: $e');
    }
    return 'Unknown Device';
  }

  Future<String> getDeviceUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'device_unique_id';
    String? existingId = prefs.getString(key);
    if (existingId != null) {
      return existingId;
    } else {
      String newId = _uuid.v4();
      await prefs.setString(key, newId);
      return newId;
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
