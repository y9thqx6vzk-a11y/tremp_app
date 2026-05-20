import '../models/trip_route.dart';

abstract class RoutingEngine {
  Future<List<TripRoute>> calculateRoutes(String origin, String destination);
  Future<TripRoute> calculateRendezvousRoute(String origin, String destination, String driverLocation);
}

class RealRoutingEngine implements RoutingEngine {
  @override
  Future<List<TripRoute>> calculateRoutes(String origin, String destination) {
    throw UnimplementedError('Real routing API not implemented yet.');
  }

  @override
  Future<TripRoute> calculateRendezvousRoute(String origin, String destination, String driverLocation) {
    throw UnimplementedError('Real rendezvous calculation not implemented yet.');
  }
}

class MockRoutingEngine implements RoutingEngine {
  @override
  Future<List<TripRoute>> calculateRoutes(String origin, String destination) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      _buildOnlyTransitRoute(origin, destination),
      _buildHybridRoute(origin, destination),
      _buildRecommendedRoute(origin, destination),
      _buildOnlyHitchhikeRoute(origin, destination),
    ];
  }

  @override
  Future<TripRoute> calculateRendezvousRoute(String origin, String destination, String driverLocation) async {
    await Future.delayed(const Duration(seconds: 2));

    final passengerDurationToSpot = const Duration(minutes: 18);
    final driverDurationToSpot = const Duration(minutes: 20);
    final delta = (passengerDurationToSpot.inMinutes - driverDurationToSpot.inMinutes).abs();

    return TripRoute(
      id: 'r_rendezvous',
      routeType: 'rendezvous',
      title: 'איסוף משולב',
      totalCost: 0,
      passengerSegments: [
        RouteSegment(
          type: TransitType.bus,
          origin: origin,
          destination: 'צומת חבירה - כביש החוף',
          duration: passengerDurationToSpot,
          description: 'נסיעה באוטובוס לצומת החבירה',
        )
      ],
      driverSegments: [
        RouteSegment(
          type: TransitType.car,
          origin: driverLocation,
          destination: 'צומת חבירה - כביש החוף',
          duration: driverDurationToSpot,
          description: 'נסיעת הנהג (דלתא המתנה בצומת: $delta דקות)',
        )
      ],
      sharedSegments: [
        RouteSegment(
          type: TransitType.car,
          origin: 'צומת חבירה - כביש החוף',
          destination: destination,
          duration: const Duration(minutes: 40),
          description: 'נסיעה משותפת עד ליעד הסופי',
          reliabilityScore: 100,
        )
      ],
    );
  }

  TripRoute _buildOnlyTransitRoute(String origin, String destination) {
    return TripRoute(
      id: 'r1',
      routeType: 'only_transit',
      title: 'רק תחב״צ',
      totalCost: 22,
      sharedSegments: [
        RouteSegment(
          type: TransitType.walk,
          origin: origin,
          destination: 'תחנה מרכזית $origin',
          duration: const Duration(minutes: 10),
          description: 'הליכה קצרה לתחנה',
        ),
        RouteSegment(
          type: TransitType.bus,
          origin: 'תחנה מרכזית $origin',
          destination: 'תחנה מרכזית $destination',
          duration: const Duration(minutes: 90),
          description: 'קו 480 ישיר למרכז',
        ),
      ],
    );
  }

  TripRoute _buildHybridRoute(String origin, String destination) {
    return TripRoute(
      id: 'r2',
      routeType: 'hybrid',
      title: 'משולב',
      totalCost: 12,
      sharedSegments: [
        RouteSegment(
          type: TransitType.bus,
          origin: origin,
          destination: 'צומת מרכזית בדרך',
          duration: const Duration(minutes: 30),
          description: 'קו אקספרס עד לצומת',
        ),
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'צומת מרכזית בדרך',
          destination: destination,
          duration: const Duration(minutes: 45),
          description: 'טרמפיאדה מבוקשת',
          reliabilityScore: 88,
        ),
      ],
    );
  }

  TripRoute _buildRecommendedRoute(String origin, String destination) {
    return TripRoute(
      id: 'r3',
      routeType: 'recommended',
      title: 'מומלץ',
      totalCost: 5,
      sharedSegments: [
        RouteSegment(
          type: TransitType.walk,
          origin: origin,
          destination: 'טרמפיאדה צפונית',
          duration: const Duration(minutes: 8),
          description: 'הליכה לטרמפיאדה',
        ),
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'טרמפיאדה צפונית',
          destination: destination,
          duration: const Duration(minutes: 60),
          description: 'טרמפ מהיר (סיכוי גבוה)',
          reliabilityScore: 95,
        ),
      ],
    );
  }

  TripRoute _buildOnlyHitchhikeRoute(String origin, String destination) {
    return TripRoute(
      id: 'r4',
      routeType: 'only_hitchhike',
      title: 'רק טרמפים',
      totalCost: 0,
      sharedSegments: [
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'יציאה מ-$origin',
          destination: destination,
          duration: const Duration(minutes: 90),
          description: 'המתנה בצומת',
          reliabilityScore: 65,
        ),
      ],
    );
  }
}
