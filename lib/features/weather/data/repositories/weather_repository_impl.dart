import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/repositories/weather_repository.dart';
import '../../domain/weather.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  // --- ⚠️ PASTE YOUR API KEY HERE ---
  final String _apiKey = 'fb1591b55a5387ca05f032f12ae2c759';

  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  @override
  Future<Weather> getWeather(String cityName) async {
    // Build the full URL: e.g., .../weather?q=London&appid=YOUR_KEY
    final url = Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey');

    try {
      // 1. Make the network request
      final response = await http.get(url);

      // 2. Check for a successful response
      if (response.statusCode == 200) {
        // 3. Decode the JSON string into a Map
        final Map<String, dynamic> json = jsonDecode(response.body);

        // 4. Use our factory constructor to parse the Map
        return Weather.fromJson(json);
      } else {
        // 5. Handle errors (e.g., city not found, invalid key)
        throw Exception('Failed to load weather: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load weather: $e');
    }
  }
}
