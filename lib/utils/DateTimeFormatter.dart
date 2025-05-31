import 'package:coin_log/constants/MonthMap.dart';

class DateTimeFormatter {
  static String toDayMonth(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}";
  }

  static String toDate(DateTime dateTime) {
    return "${dateTime.day} ${monthMap[dateTime.month.toString()]} ${dateTime.year}";
  }
}