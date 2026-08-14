import 'package:timezone/timezone.dart' as tz;
import 'package:fourteen_november/features/user/user.dart';

class Weather {
  final String id;

  /// Nearest resolved locality. With a precise fix this can be a
  /// neighbourhood rather than the city, so [region] is often the friendlier
  /// label of the two.
  final String name;

  /// Wider administrative area, e.g. "Tehran" for a district within it.
  final String region;

  final String country;

  final DateTime localtime;

  final bool isDay;

  final int tempC;

  final String conditionIcon;

  final User user;

  Weather({
    required this.id,
    required this.name,
    required this.region,
    required this.country,
    required this.localtime,
    required this.isDay,
    required this.tempC,
    required this.conditionIcon,
    required this.user,
  });

  factory Weather.fromJson({required dynamic json, required User user}) {
    _validate(json);

    final location = json["location"] as Map<String, dynamic>?;
    final current = json["current"] as Map<String, dynamic>?;
    final condition = current?["condition"] as Map<String, dynamic>?;
    final conditionIcon = (condition!["icon"] as String).replaceFirst(
      '//cdn',
      'https://cdn',
    );

    final locationTz = tz.getLocation(location?["tz_id"]);
    final localtime = tz.TZDateTime.now(locationTz);

    return Weather(
      id: (location!["name"] ?? "").toString().toLowerCase(),
      name: location["name"],
      region: (location["region"] as String?) ?? '',
      country: location["country"],
      localtime: DateTime(
        localtime.year,
        localtime.month,
        localtime.day,
        localtime.hour,
        localtime.minute,
        localtime.second,
        localtime.millisecond,
        localtime.microsecond,
      ),
      isDay: current!["is_day"] == 1,
      tempC: (current["temp_c"] as num).round(),
      conditionIcon: conditionIcon,
      user: user,
    );
  }

  static void _validate(dynamic json) {
    final location = json["location"] as Map<String, dynamic>?;
    final current = json["current"] as Map<String, dynamic>?;
    final condition = current?["condition"] as Map<String, dynamic>?;

    if (location == null ||
        current == null ||
        condition == null ||
        location["name"] is! String ||
        location["country"] is! String ||
        location["tz_id"] is! String ||
        current["is_day"] is! num ||
        current["temp_c"] is! num ||
        condition["icon"] is! String) {
      throw Exception('Invalid json payload for Weather.fromJson');
    }
  }
}
