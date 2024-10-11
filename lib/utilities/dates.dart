import 'package:intl/intl.dart';

String formattedDateTime(String dateTimeString) {
  DateTime parsedDateTime = DateTime.parse(dateTimeString);
  String formattedDate = DateFormat('MMMM d, y').format(parsedDateTime);
  String formattedTime = DateFormat('h:mm a').format(parsedDateTime);

  return '$formattedDate on $formattedTime';
}