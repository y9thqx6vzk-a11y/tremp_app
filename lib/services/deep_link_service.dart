import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:geolocator/geolocator.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  
  // Callback when a rendezvous link is received: (origin, destination, driverLocation)
  Function(String, String, String)? onRendezvousRequest;

  void init() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Expected format: trempapp://rendezvous?origin=X&destination=Y
    if (uri.scheme == 'trempapp' && uri.host == 'rendezvous') {
      final origin = uri.queryParameters['origin'];
      final destination = uri.queryParameters['destination'];

      if (origin != null && destination != null) {
        // We received a rendezvous request. Now sample driver's GPS.
        final driverLocation = await _sampleDriverLocation();
        if (onRendezvousRequest != null) {
          onRendezvousRequest!(origin, destination, driverLocation);
        }
      }
    }
  }

  Future<String> _sampleDriverLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'מיקום לא ידוע (GPS כבוי)';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'מיקום לא ידוע (ללא הרשאה)';
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return 'מיקום לא ידוע (הרשאה חסומה)';
    }

    // Attempt to get high-accuracy position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      // In a real app, reverse geocode this. For mock, we return the coords.
      return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      return 'שגיאה בקריאת מיקום';
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
