import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trip_route.dart';
import '../../data/services/routing_engine.dart';
import '../../main.dart'; // To access getIt

// Provider for Dependency Injection using GetIt
final routingEngineProvider = Provider<RoutingEngine>((ref) => getIt<RoutingEngine>());

class RouteRequest {
  final String origin;
  final String destination;
  final String? driverLocation;

  RouteRequest({
    required this.origin,
    required this.destination,
    this.driverLocation,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RouteRequest &&
      other.origin == origin &&
      other.destination == destination &&
      other.driverLocation == driverLocation;
  }

  @override
  int get hashCode => origin.hashCode ^ destination.hashCode ^ driverLocation.hashCode;
}

final routesProvider = FutureProvider.family<List<TripRoute>, RouteRequest>((ref, request) async {
  final routingEngine = ref.read(routingEngineProvider);
  
  final routes = await routingEngine.calculateRoutes(request.origin, request.destination);
  
  if (request.driverLocation != null) {
    final rendezvous = await routingEngine.calculateRendezvousRoute(
      request.origin, 
      request.destination, 
      request.driverLocation!
    );
    // Insert at the beginning so it's the first tab shown
    routes.insert(0, rendezvous);
  }
  
  return routes;
});
