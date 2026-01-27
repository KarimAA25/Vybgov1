import 'package:admin/app/constant/show_toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class Utils {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Location().requestService();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    while (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        ShowToastDialog.errorToast("Permission Required.\nPlease allow location to continue.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ShowToastDialog.errorToast("Permission Required.\nLocation permission is permanently denied. Please enable it from Settings.");
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }
}
