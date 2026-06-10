import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/public_holiday.dart';

abstract class HolidayService {
  Future<bool> isPublicHoliday(DateTime date);
  Future<List<PublicHoliday>> fetchHolidays(int year);
}

class NagerDateHolidayService implements HolidayService {
  static const String _countryCode = 'ID';
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  List<PublicHoliday>? _cachedHolidays;
  int? _cachedYear;

  @override
  Future<bool> isPublicHoliday(DateTime date) async {
    final holidays = await _getHolidays(date.year);
    final targetDate = _normalizeDate(date);

    return holidays.any((holiday) => holiday.date == targetDate);
  }

  @override
  Future<List<PublicHoliday>> fetchHolidays(int year) async {
    return _getHolidays(year);
  }

  Future<List<PublicHoliday>> _getHolidays(int year) async {
    if (_cachedYear == year && _cachedHolidays != null) {
      return List<PublicHoliday>.unmodifiable(_cachedHolidays!);
    }

    final uri = Uri.parse('$_baseUrl/PublicHolidays/$year/$_countryCode');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load public holidays for year $year');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid holiday response format');
    }

    final holidays = decoded
        .map((item) => PublicHoliday.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    _cachedYear = year;
    _cachedHolidays = holidays;

    return List<PublicHoliday>.unmodifiable(holidays);
  }

  String _normalizeDate(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
