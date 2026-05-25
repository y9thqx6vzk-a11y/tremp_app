import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/trip_route.dart';

class PublicTransitService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch real-time transit segments using our Supabase Edge Function.
  /// The Edge Function handles the heavy lifting of parsing GTFS/SIRI from Israel's MoT.
  Future<List<RouteSegment>> fetchRealtimeTransit(double originLat, double originLon, double destLat, double destLon) async {
    try {
      final response = await _client.functions.invoke('siri-proxy', body: {
        'originLat': originLat,
        'originLon': originLon,
        'destLat': destLat,
        'destLon': destLon,
      });

      final data = response.data;
      if (data != null && data['segments'] != null) {
        return (data['segments'] as List).map((seg) => RouteSegment(
          type: TransitType.bus,
          origin: seg['origin'] ?? '',
          destination: seg['destination'] ?? '',
          duration: Duration(minutes: seg['durationMinutes'] ?? 0),
          description: seg['description'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      // Return empty list on failure, graceful degradation
      return [];
    }
  }
}
