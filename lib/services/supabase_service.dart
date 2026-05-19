import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride.dart';

class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool get isSupabaseInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Local mock database in case Supabase is not configured yet
  final List<Ride> _mockRides = [
    Ride(
      id: '1',
      driverName: 'איל גרנות',
      origin: 'תל אביב',
      destination: 'ירושלים',
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      availableSeats: 3,
      notes: 'נוסע דרך כביש 1, גמיש לאסוף מהרכבת',
      passengers: ['דנה'],
    ),
    Ride(
      id: '2',
      driverName: 'מיכל כהן',
      origin: 'חיפה',
      destination: 'תל אביב',
      departureTime: DateTime.now().add(const Duration(hours: 4)),
      availableSeats: 2,
      notes: 'שומר שבת, לא מעשנים באוטו',
      passengers: [],
    ),
    Ride(
      id: '3',
      driverName: 'דוד לוי',
      origin: 'באר שבע',
      destination: 'תל אביב',
      departureTime: DateTime.now().add(const Duration(days: 1)),
      availableSeats: 4,
      notes: 'יש מקום להרבה ציוד בבגאז׳',
      passengers: [],
    ),
  ];

  // Get all active rides
  Future<List<Ride>> getRides() async {
    if (!isSupabaseInitialized) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return List.from(_mockRides);
    }

    try {
      final response = await Supabase.instance.client
          .from('rides')
          .select()
          .order('departure_time', ascending: true);
      
      return (response as List).map((json) => Ride.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching rides from Supabase: $e');
      return List.from(_mockRides); // Fallback to mock data on error
    }
  }

  // Create a new ride
  Future<bool> createRide(Ride ride) async {
    if (!isSupabaseInitialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newRide = Ride(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverName: ride.driverName,
        origin: ride.origin,
        destination: ride.destination,
        departureTime: ride.departureTime,
        availableSeats: ride.availableSeats,
        notes: ride.notes,
        passengers: [],
      );
      _mockRides.insert(0, newRide);
      return true;
    }

    try {
      await Supabase.instance.client
          .from('rides')
          .insert(ride.toJson());
      return true;
    } catch (e) {
      print('Error creating ride in Supabase: $e');
      return false;
    }
  }

  // Join an existing ride
  Future<bool> joinRide(String rideId, String passengerName) async {
    if (!isSupabaseInitialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockRides.indexWhere((r) => r.id == rideId);
      if (index != -1) {
        final ride = _mockRides[index];
        if (ride.availableSeats > 0 && !ride.passengers.contains(passengerName)) {
          _mockRides[index] = Ride(
            id: ride.id,
            driverName: ride.driverName,
            origin: ride.origin,
            destination: ride.destination,
            departureTime: ride.departureTime,
            availableSeats: ride.availableSeats - 1,
            notes: ride.notes,
            passengers: [...ride.passengers, passengerName],
          );
          return true;
        }
      }
      return false;
    }

    try {
      // 1. Fetch current ride
      final response = await Supabase.instance.client
          .from('rides')
          .select()
          .eq('id', rideId)
          .single();
      
      final ride = Ride.fromJson(response);
      
      if (ride.availableSeats <= 0 || ride.passengers.contains(passengerName)) {
        return false;
      }

      // 2. Update passengers and seats
      await Supabase.instance.client
          .from('rides')
          .update({
            'available_seats': ride.availableSeats - 1,
            'passengers': [...ride.passengers, passengerName],
          })
          .eq('id', rideId);
      
      return true;
    } catch (e) {
      print('Error joining ride in Supabase: $e');
      return false;
    }
  }

  // Search/Filter rides
  Future<List<Ride>> searchRides(String origin, String destination) async {
    final allRides = await getRides();
    return allRides.where((ride) {
      final matchesOrigin = origin.isEmpty || 
          ride.origin.toLowerCase().contains(origin.toLowerCase());
      final matchesDestination = destination.isEmpty || 
          ride.destination.toLowerCase().contains(destination.toLowerCase());
      return matchesOrigin && matchesDestination;
    }).toList();
  }
}
