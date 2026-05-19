class Ride {
  final String id;
  final String driverName;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final int availableSeats;
  final String notes;
  final List<String> passengers;

  Ride({
    required this.id,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.notes,
    required this.passengers,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String? ?? '',
      driverName: json['driver_name'] as String? ?? 'נהג אנונימי',
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      departureTime: DateTime.parse(json['departure_time'] as String? ?? DateTime.now().toIso8601String()),
      availableSeats: json['available_seats'] as int? ?? 4,
      notes: json['notes'] as String? ?? '',
      passengers: List<String>.from(json['passengers'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_name': driverName,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'available_seats': availableSeats,
      'notes': notes,
      'passengers': passengers,
    };
  }
}
