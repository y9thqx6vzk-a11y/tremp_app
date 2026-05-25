import 'package:geolocator/geolocator.dart';

class LocationService {
  /// בדיקת הרשאות וגישה למיקום (כולל הכנה למיקום רקע שמוגדר ברמת ה-OS)
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// האזנה למיקום באופן רציף (בפוקוס וברקע, בהתאם להרשאות ה-Manifest/Info.plist)
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // עדכון המיקום כל 10 מטרים לחיסכון בסוללה
      ),
    );
  }
  
  /// קבלת מיקום חד פעמי
  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
