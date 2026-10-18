import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherDataFetcher {
  final String apiKey = dotenv.env['apiKeyW'] ?? 'no';

  Future<List<Map<String, dynamic>>> fetchWeather() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied forever.');
      }
    }

    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final double latitude = position.latitude;
    final double longitude = position.longitude;

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map || decoded['daily'] is! Map) {
          throw const FormatException('Weather response is invalid.');
        }
        final data = Map<String, dynamic>.from(decoded);
        final daily = Map<String, dynamic>.from(decoded['daily'] as Map);
        final dates = daily['time'];
        if (dates is! List) {
          throw const FormatException('Weather forecast has no dates.');
        }
        // Build a forecast list for 7 days
        var forecast = List<Map<String, dynamic>>.generate(
          dates.length < 7 ? dates.length : 7,
          (index) => {
            'date': dates[index],
            'day': DateFormat('EEEE')
                .format(DateTime.parse(dates[index].toString())),
            'max_temp': (daily['temperature_2m_max'] as List)[index],
            'min_temp': (daily['temperature_2m_min'] as List)[index],
            'weathercode': (daily['weathercode'] as List)[index],
          },
        );
        return forecast;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }
}
