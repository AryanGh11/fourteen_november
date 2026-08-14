import 'package:geolocator/geolocator.dart';

part './failure_enum.dart';
part './models/result.dart';

/// Reads the device's current coordinates.
///
/// Only ever called on demand: there is no background tracking and no stream,
/// so nothing here runs unless something explicitly asks for a fix.
class LocationService {
  /// How long to wait for a fix before giving up.
  ///
  /// A bounded wait matters more than a precise one here: indoors a request
  /// can otherwise hang indefinitely while the UI shows a spinner.
  static const Duration _timeout = Duration(seconds: 15);

  /// Requests a single fix, asking for permission if it has not been granted.
  ///
  /// Never throws for the ordinary refusals; those come back as a
  /// [LocationFailure] so the caller can decide what to show.
  static Future<LocationResult> current({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    // Checked first because permission can be granted while the device's
    // location is switched off entirely, in which case no fix will ever arrive.
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult.failed(LocationFailure.serviceDisabled);
    }

    final permission = await _ensurePermission();

    if (permission != null) return LocationResult.failed(permission);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: _timeout,
        ),
      );

      return LocationResult.success(position);
    } catch (_) {
      // Timeouts and "no fix" both surface as exceptions from the platform.
      return const LocationResult.failed(LocationFailure.unavailable);
    }
  }

  /// Returns `null` when permission is usable, or the reason it is not.
  static Future<LocationFailure?> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return null;
      case LocationPermission.deniedForever:
        return LocationFailure.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationFailure.denied;
    }
  }

  /// Opens the OS settings page for this app.
  ///
  /// The only way out of [LocationFailure.deniedForever], since the system
  /// will not show the prompt again.
  static Future<bool> openSettings() => Geolocator.openAppSettings();

  /// Opens the device's location settings page.
  ///
  /// The way out of [LocationFailure.serviceDisabled].
  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();
}
