import '../models/trip_route.dart';

class RoutingEngine {
  // Singleton pattern
  static final RoutingEngine _instance = RoutingEngine._internal();
  factory RoutingEngine() => _instance;
  RoutingEngine._internal();

  Future<List<TripRoute>> calculateRoutes(String origin, String destination) async {
    // Simulate network calculation delay
    await Future.delayed(const Duration(seconds: 2));

    // For demonstration, we generate 4 hardcoded dynamic-like routes
    // based on the requested origin and destination.

    return [
      _buildOnlyTransitRoute(origin, destination),
      _buildHybridRoute(origin, destination),
      _buildRecommendedRoute(origin, destination),
      _buildOnlyHitchhikeRoute(origin, destination),
    ];
  }

  TripRoute _buildOnlyTransitRoute(String origin, String destination) {
    return TripRoute(
      id: 'r1',
      routeType: 'only_transit',
      title: 'רק תחב״צ',
      totalCost: 22,
      segments: [
        RouteSegment(
          type: TransitType.walk,
          origin: origin,
          destination: 'תחנה מרכזית $origin',
          duration: const Duration(minutes: 10),
          description: 'הליכה קצרה לתחנה המרכזית',
        ),
        RouteSegment(
          type: TransitType.bus,
          origin: 'תחנה מרכזית $origin',
          destination: 'תחנה מרכזית $destination',
          duration: const Duration(minutes: 90),
          description: 'קו 480 ישיר למרכז',
        ),
        RouteSegment(
          type: TransitType.walk,
          origin: 'תחנה מרכזית $destination',
          destination: destination,
          duration: const Duration(minutes: 5),
          description: 'הליכה ליעד',
        ),
      ],
    );
  }

  TripRoute _buildHybridRoute(String origin, String destination) {
    return TripRoute(
      id: 'r2',
      routeType: 'hybrid',
      title: 'תחב״צ + טרמפים',
      totalCost: 12,
      segments: [
        RouteSegment(
          type: TransitType.bus,
          origin: origin,
          destination: 'צומת מרכזית בדרך',
          duration: const Duration(minutes: 30),
          description: 'קו אקספרס עד לצומת הראשית',
        ),
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'צומת מרכזית בדרך',
          destination: 'צומת בכניסה ל-$destination',
          duration: const Duration(minutes: 45),
          description: 'טרמפיאדה מבוקשת עם המון חיילים',
          reliabilityScore: 88,
        ),
        RouteSegment(
          type: TransitType.walk,
          origin: 'צומת בכניסה ל-$destination',
          destination: destination,
          duration: const Duration(minutes: 15),
          description: 'הליכה נעימה עד ליעד',
        ),
      ],
    );
  }

  TripRoute _buildRecommendedRoute(String origin, String destination) {
    return TripRoute(
      id: 'r3',
      routeType: 'recommended',
      title: 'הדרך המומלצת',
      totalCost: 5,
      segments: [
        RouteSegment(
          type: TransitType.walk,
          origin: origin,
          destination: 'טרמפיאדה צפונית $origin',
          duration: const Duration(minutes: 8),
          description: 'הליכה לטרמפיאדה הקרובה (מוצלת בקיץ)',
        ),
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'טרמפיאדה צפונית $origin',
          destination: 'תחנת רכבת ב-$destination',
          duration: const Duration(minutes: 60),
          description: 'טרמפ מהיר על כביש 6 (סיכוי גבוה לרכב פרטי)',
          reliabilityScore: 95,
        ),
        RouteSegment(
          type: TransitType.train,
          origin: 'תחנת רכבת ב-$destination',
          destination: destination,
          duration: const Duration(minutes: 15),
          description: 'רכבת ליעד הסופי במרכז העיר',
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
      segments: [
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'יציאה מ-$origin',
          destination: 'צומת מעבר (אמצע הדרך)',
          duration: const Duration(minutes: 40),
          description: 'טרמפיאדה פחות עמוסה, זמן המתנה משוער: 15 דק׳',
          reliabilityScore: 65,
        ),
        RouteSegment(
          type: TransitType.hitchhike,
          origin: 'צומת מעבר (אמצע הדרך)',
          destination: 'כניסה ל-$destination',
          duration: const Duration(minutes: 50),
          description: 'תחנת דלק בדרך, הרבה נהגים עוצרים כאן',
          reliabilityScore: 82,
        ),
      ],
    );
  }
}
