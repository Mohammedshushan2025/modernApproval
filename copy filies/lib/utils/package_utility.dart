import 'package:intl/intl.dart';



// دالة لتنسيق التاريخ بشكل موحد
String formatDate(DateTime? date) {
  if (date == null) {
    return 'N/A';
  }
  // يمكنك تغيير التنسيق هنا بسهولة
  // مثال: 'yyyy-MM-dd' أو 'dd MMMM yyyy'
  return DateFormat('yyyy/MM/dd').format(date);
}
