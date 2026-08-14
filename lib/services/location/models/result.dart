part of '../location_service.dart';

/// The outcome of a location request: a [position] or a [failure], never both.
class LocationResult {
  final Position? position;
  final LocationFailure? failure;

  const LocationResult.success(Position this.position) : failure = null;
  const LocationResult.failed(LocationFailure this.failure) : position = null;

  bool get isSuccess => position != null;
}
