import 'package:intl/intl.dart' as intl;

class DateFormatter {
  static String format({
    required DateTime date,
    String pattern = 'dd MMM yyyy, HH:mm',
  }) => intl.DateFormat(pattern).format(date);
}
