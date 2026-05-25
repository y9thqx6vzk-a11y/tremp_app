enum TransitType { bus, train, walk, hitchhike, car }

class RouteSegment {
  final TransitType type;
  final String origin;
  final String destination;
  final Duration duration;
  final String description;
  final int? reliabilityScore;

  RouteSegment({
    required this.type,
    required this.origin,
    required this.destination,
    required this.duration,
    required this.description,
    this.reliabilityScore,
  });

  String get typeName {
    switch (type) {
      case TransitType.bus:
        return 'אוטובוס';
      case TransitType.train:
        return 'רכבת';
      case TransitType.walk:
        return 'הליכה';
      case TransitType.hitchhike:
        return 'טרמפ';
      case TransitType.car:
        return 'רכב פרטי';
    }
  }
}

class TripRoute {
  final String id;
  final String routeType; 
  final String title;
  
  // Breaking Change from User Request: Splitting to Y-Graph
  final List<RouteSegment>? passengerSegments;
  final List<RouteSegment>? driverSegments;
  final List<RouteSegment> sharedSegments;
  
  final int totalCost;

  TripRoute({
    required this.id,
    required this.routeType,
    required this.title,
    this.passengerSegments,
    this.driverSegments,
    required this.sharedSegments,
    this.totalCost = 0,
  });

  Duration get totalDuration {
    final passengerDuration = passengerSegments?.fold(
      const Duration(),
      (previousValue, segment) => previousValue + segment.duration,
    ) ?? const Duration();

    // The shared duration happens after the rendezvous
    final sharedDuration = sharedSegments.fold(
      const Duration(),
      (previousValue, segment) => previousValue + segment.duration,
    );

    return passengerDuration + sharedDuration;
  }

  int get averageReliabilityScore {
    final allSegments = [
      ...?passengerSegments,
      ...?driverSegments,
      ...sharedSegments,
    ];
    final hitchhikeSegments = allSegments.where((s) => s.type == TransitType.hitchhike).toList();
    
    if (hitchhikeSegments.isEmpty) return 100;
    
    final totalScore = hitchhikeSegments.fold<int>(
      0,
      (previousValue, segment) => previousValue + (segment.reliabilityScore ?? 50),
    );
    return (totalScore / hitchhikeSegments.length).round();
  }
}
