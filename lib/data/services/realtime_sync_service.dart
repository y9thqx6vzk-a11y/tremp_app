import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeSyncService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  /// מתחבר לערוץ בזמן אמת של נקודת החבירה (Rendezvous)
  void joinRendezvousChannel(String rendezvousId, Function(Map<String, dynamic>) onLocationUpdate) {
    _channel = _client.channel('rendezvous:$rendezvousId');
    
    _channel!
      .onBroadcast(
        event: 'location_update',
        callback: (payload) {
          onLocationUpdate(payload);
        },
      )
      .subscribe();
  }

  /// משדר את המיקום הנוכחי למשתתף השני בערוץ
  Future<void> broadcastLocation(String rendezvousId, double lat, double lon, String role) async {
    if (_channel != null) {
      await _channel!.sendBroadcastMessage(
        event: 'location_update',
        payload: {
          'role': role,
          'lat': lat,
          'lon': lon,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// יציאה מהערוץ
  void leaveChannel() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
