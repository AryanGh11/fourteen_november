import 'dart:io';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/weather/weather.dart';

// TODO: doc
class WeatherController {
  final http = HttpClient();

  final String _baseApiUrl = 'http://api.weatherapi.com/v1';
  final String _apiKey = '72f05ab0f25a4cbe8df102454262105';

  Future<Weather> getCurrentFor({
    required String cityName,
    required User user,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseApiUrl/current.json?key=$_apiKey&q=$cityName',
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
