import 'package:coin_log/constants/MonthMap.dart';

class DateTimeFormatter {
  static String toDayMonth(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}";
  }

  static String toDate(DateTime dateTime) {
    return "${dateTime.day} ${monthMap[dateTime.month.toString()]} ${dateTime.year}";
  }

  static String toTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}