extension DurationExtension on Duration {
  String get prettyInDays {
    final days = inDays;
    final hours = inHours.remainder(24);
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    return '$days d $hours h $minutes m $seconds s';
  }

  String get prettyInMonths {
    final months = inDays ~/ 30;

    final days = inDays % 30;

    if (months == 0) {
      return '$days Day${days == 1 ? '' : 's'}';
    }

    if (days == 0) {
      return '$months Month${months == 1 ? '' : 's'}';
    }

    return '$months Month${months == 1 ? '' : 's'} '
        '$days Day${days == 1 ? '' : 's'}';
  }
}
