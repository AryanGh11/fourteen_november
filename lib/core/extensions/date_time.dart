extension DateTimeExtension on DateTime {
  String getTogetherFor(DateTime from) {
    final now = DateTime.now();

    int years = now.year - from.year;
    int months = now.month - from.month;
    int days = now.day - from.day;

    if (days < 0) {
      months--;
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return '${years != 0 ? years : ''} $months m $days d';
  }
}
