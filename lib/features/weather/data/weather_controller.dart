import 'dart:io';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/weather/weather.dart';

/// Talks to the weather API.
///
/// Queried by coordinate rather than by city name: `q` accepts `lat,lon`, and
/// the response carries the resolved place name. That makes the location the
/// single source of truth, so the name follows whoever moves without anything
/// having to be typed in or kept up to date.
class WeatherController {
  final http = HttpClient();

  // https rather than http: Android blocks cleartext traffic by default from
  // API 28 up, so the plain http endpoint fails there while working on iOS.
  final String _baseApiUrl = 'https://api.weatherapi.com/v1';
  final String _apiKey = '72f05ab0f25a4cbe8df102454262105';

  Future<Weather> getCurrentFor({required User user}) async {
    try {
      final query = '${user.locationLat},${user.locationLng}';

      final url = Uri.parse(
        '$_baseApiUrl/current.json?key=$_apiKey&q=$query',
      );

      final request = await http.getUrl(url);

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);

      return Weather.fromJson(json: json, user: user);
    } catch (e) {
      debugPrint("Weather getCurrentFor failed: $e");
      rethrow;
    }
  }
}
