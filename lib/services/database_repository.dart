import '../models/hitchhiking_spot.dart';

abstract class DatabaseRepository {
  Future<List<HitchhikingSpot>> getHitchhikingSpots();
}

class MockDatabaseRepository implements DatabaseRepository {
  @override
  Future<List<HitchhikingSpot>> getHitchhikingSpots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      HitchhikingSpot(
        id: '1',
        name: 'צומת רעננה צפון',
        latitude: 32.1950,
        longitude: 34.8875,
        broomsScore: 85,
      ),
      HitchhikingSpot(
        id: '2',
        name: 'צומת קסטינה',
        latitude: 31.7335,
        longitude: 34.7570,
        broomsScore: 92,
      ),
      HitchhikingSpot(
        id: '3',
        name: 'צומת גלילות',
        latitude: 32.1465,
        longitude: 34.8040,
        broomsScore: 78,
      ),
      HitchhikingSpot(
        id: '4',
        name: 'כניסה לירושלים (גינות סחרוב)',
        latitude: 31.7944,
        longitude: 35.1852,
        broomsScore: 95,
      ),
    ];
  }
}

class SupabaseDatabaseRepository implements DatabaseRepository {
  // final SupabaseClient _client;
  // SupabaseDatabaseRepository(this._client);

  @override
  Future<List<HitchhikingSpot>> getHitchhikingSpots() {
    throw UnimplementedError('Real Supabase query not implemented yet.');
  }
}
