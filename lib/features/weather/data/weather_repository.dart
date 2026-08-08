import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/weather/data/weather_controller.dart';
import 'package:fourteen_november/features/weather/weather.dart';

/// Repository responsible for managing cached [Weather] data.
///
/// This repository follows an offline-first architecture:
/// - Hive is used as the primary local data source.
/// - PocketBase is used as the remote source of truth.
/// - UI reads data directly from local cache for fast and stable rendering.
/// - Remote synchronization happens manually through refresh methods.
///
/// The repository provides:
/// - Instant local reads
/// - Initial synchronization
/// - Manual remote refresh support
/// - Persistent offline access

// TODO: doc
class WeatherRepository {
  final _controller = WeatherController();

  Future<Weather> getCurrentFor({
    required String cityName,
    required User user,
  }) async {
    return await _controller.getCurrentFor(cityName: cityName, user: user);
  }
}
