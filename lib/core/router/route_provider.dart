class RouteProvider {
  static String get home => "/";

  static String get moods => "/moods";

  static String get gym => "/gym";

  static String get periods => "/periods";

  static String get posts => "/posts";
  static String get newPost => "/newPost";

  static String get weather => "/weather";

  static String get stats => "/stats";

  static String get backgrounds => "/backgrounds";

  static String get profile => "/profile";

  /// Route pattern for a gift; open one with [gift].
  static String get giftPattern => "/gift/:id";
  static String gift(String id) => "/gift/$id";
}
