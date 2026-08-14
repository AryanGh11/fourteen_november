part of './location_service.dart';

/// Why a location request did not produce a coordinate.
///
/// Separated from a plain `null` so callers can tell the user what to do:
/// switching on GPS and opening app settings are different fixes, and a
/// permanently denied permission cannot be re-requested from inside the app.
enum LocationFailure {
  /// Location services are switched off device wide.
  serviceDisabled,

  /// The user declined this time; asking again later is allowed.
  denied,

  /// The user declined permanently, or the platform blocks the prompt. Only
  /// app settings can change this, so re-prompting does nothing.
  deniedForever,

  /// A fix was requested but none arrived, usually indoors or on timeout.
  unavailable,
}
