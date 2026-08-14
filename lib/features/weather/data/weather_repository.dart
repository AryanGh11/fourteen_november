import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/weather/data/weather_controller.dart';
import 'package:fourteen_november/features/weather/weather.dart';

/// Repository responsible for fetching [Weather] data.
///
/// Deliberately the one repository that is not offline-first, and so does not
/// implement `BaseRepository`: weather is only true for the minute it was read,
/// where a post or a mood stays true once written. Caching it in Hive would
/// mean showing a temperature from hours ago as though it were current, which
/// is worse than showing nothing, so every read goes to the network.
///
/// The trade-off is that this screen needs a connection, unlike the rest of the
/// app. That is why the UI drives it with an explicit refresh and its own
/// loading and error states, rather than reading from a box.
///
/// Weather is looked up by the user's coordinates rather than by a stored city
/// name, so the place follows whoever is holding the phone. See
/// [WeatherController] for why that also removes the need to store a city.
class WeatherRepository {
  final _controller = WeatherController();

  /// Current weather where [user] is right now, resolved from their
  /// coordinates.
  Future<Weather> getCurrentFor({required User user}) async {
    return await _controller.getCurrentFor(user: user);
  }
}
