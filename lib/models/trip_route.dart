enum TransitType { bus, train, walk, hitchhike }

class RouteSegment {
  final TransitType type;
  final String origin;
  final String destination;
  final Duration duration;
  final String description;
  final int? reliabilityScore; // Brooms Score (1-100) for hitchhiking

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
    }
  }
}

class TripRoute {
  final String id;
  final String routeType; // 'only_transit', 'hybrid', 'recommended', 'only_hitchhike'
  final String title;
  final List<RouteSegment> segments;
  final int totalCost;

  TripRoute({
    required this.id,
    required this.routeType,
    required this.title,
    required this.segments,
    this.totalCost = 0,
  });

  Duration get totalDuration {
    return segments.fold(
      const Duration(),
      (previousValue, segment) => previousValue + segment.duration,
    );
  }

  int get averageReliabilityScore {
    final hitchhikeSegments = segments.where((s) => s.type == TransitType.hitchhike).toList();
    if (hitchhikeSegments.isEmpty) return 100; // Transit is considered 100% reliable
    
    final totalScore = hitchhikeSegments.fold<int>(
      0,
      (previousValue, segment) => previousValue + (segment.reliabilityScore ?? 50),
    );
    return (totalScore / hitchhikeSegments.length).round();
  }
}
