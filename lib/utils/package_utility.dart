import 'package:intl/intl.dart';




String formatDate(DateTime? date) {
  if (date == null) {
    return 'N/A';
  }

  return DateFormat('yyyy/MM/dd').format(date);
}
