import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/location_result.dart';

class GeocodingService {
  Future<List<LocationResult>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=il&accept-language=he');
        
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'TrempApp/1.0', // Required by Nominatim Policy
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LocationResult.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      return [];
    }
  }
}
