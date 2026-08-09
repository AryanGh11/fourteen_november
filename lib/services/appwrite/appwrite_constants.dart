/// Identifiers of the remote Appwrite resources used by the app.
///
/// These are not secrets. The project id ships inside the app bundle and is
/// meant to be public; access is controlled by the permissions configured on
/// each table and bucket.
class AppwriteConstants {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = 'fourteen-november';

  /// The single database holding every table.
  static const String databaseId = 'main';

  /// The single bucket holding every uploaded file (avatars, backgrounds and
  /// post attachments). One bucket keeps us well inside the free plan limits.
  static const String mediaBucketId = 'media';
}

/// Table ids, replacing the former PocketBase collection names.
class AppwriteTables {
  static const String backgrounds = 'backgrounds';
  static const String comments = 'comments';
  static const String moods = 'moods';
  static const String posts = 'posts';
  static const String users = 'users';
}
