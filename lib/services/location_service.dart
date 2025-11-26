import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];

        return "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      } else {
        return "الموقع غير متوفر حالياً";
      }
    } catch (e) {
      return "لا يمكن تحديد الموقع";
    }
  }
}
