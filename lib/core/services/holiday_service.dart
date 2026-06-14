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
  static const Map<int, List<PublicHoliday>> _fallbackHolidays = {
    2026: [
      PublicHoliday(
        date: '2026-01-01',
        localName: 'Tahun Baru Masehi',
        name: 'New Year\'s Day',
      ),
      PublicHoliday(
        date: '2026-01-16',
        localName: 'Isra Mikraj Nabi Muhammad SAW',
        name: 'Isra and Mi\'raj',
      ),
      PublicHoliday(
        date: '2026-02-17',
        localName: 'Tahun Baru Imlek',
        name: 'Chinese New Year',
      ),
      PublicHoliday(
        date: '2026-03-19',
        localName: 'Hari Suci Nyepi',
        name: 'Day of Silence',
      ),
      PublicHoliday(
        date: '2026-03-21',
        localName: 'Hari Raya Idul Fitri',
        name: 'Eid al-Fitr',
      ),
      PublicHoliday(
        date: '2026-03-22',
        localName: 'Hari Raya Idul Fitri',
        name: 'Eid al-Fitr Holiday',
      ),
      PublicHoliday(
        date: '2026-04-03',
        localName: 'Wafat Yesus Kristus',
        name: 'Good Friday',
      ),
      PublicHoliday(
        date: '2026-04-05',
        localName: 'Hari Paskah',
        name: 'Easter Sunday',
      ),
      PublicHoliday(
        date: '2026-05-01',
        localName: 'Hari Buruh Internasional',
        name: 'International Workers\' Day',
      ),
      PublicHoliday(
        date: '2026-05-14',
        localName: 'Kenaikan Yesus Kristus',
        name: 'Ascension Day',
      ),
      PublicHoliday(
        date: '2026-05-27',
        localName: 'Hari Raya Idul Adha',
        name: 'Eid al-Adha',
      ),
      PublicHoliday(
        date: '2026-05-31',
        localName: 'Hari Raya Waisak',
        name: 'Vesak Day',
      ),
      PublicHoliday(
        date: '2026-06-01',
        localName: 'Hari Lahir Pancasila',
        name: 'Pancasila Day',
      ),
      PublicHoliday(
        date: '2026-06-16',
        localName: 'Tahun Baru Islam',
        name: 'Islamic New Year',
      ),
      PublicHoliday(
        date: '2026-08-17',
        localName: 'Hari Kemerdekaan Republik Indonesia',
        name: 'Independence Day',
      ),
      PublicHoliday(
        date: '2026-08-25',
        localName: 'Maulid Nabi Muhammad SAW',
        name: 'Prophet\'s Birthday',
      ),
      PublicHoliday(
        date: '2026-12-25',
        localName: 'Hari Raya Natal',
        name: 'Christmas Day',
      ),
    ],
  };

  final Map<int, List<PublicHoliday>> _cachedHolidaysByYear = {};

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
    final cachedHolidays = _cachedHolidaysByYear[year];
    if (cachedHolidays != null) {
      return List<PublicHoliday>.unmodifiable(cachedHolidays);
    }

    late final List<PublicHoliday> holidays;
    try {
      final uri = Uri.parse('$_baseUrl/PublicHolidays/$year/$_countryCode');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load public holidays for year $year');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Invalid holiday response format');
      }

      final holidaysFromApi = decoded
          .map((item) => PublicHoliday.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      holidays = _mergeWithFallback(year, holidaysFromApi);
    } catch (_) {
      final fallbackHolidays = _fallbackHolidays[year];
      if (fallbackHolidays == null) rethrow;
      holidays = List<PublicHoliday>.from(fallbackHolidays)
        ..sort((a, b) => a.date.compareTo(b.date));
    }

    _cachedHolidaysByYear[year] = holidays;

    return List<PublicHoliday>.unmodifiable(holidays);
  }

  List<PublicHoliday> _mergeWithFallback(
    int year,
    List<PublicHoliday> holidaysFromApi,
  ) {
    final byDate = <String, PublicHoliday>{
      for (final holiday in holidaysFromApi) holiday.date: holiday,
    };

    for (final fallbackHoliday in _fallbackHolidays[year] ?? const <PublicHoliday>[]) {
      byDate.putIfAbsent(fallbackHoliday.date, () => fallbackHoliday);
    }

    final holidays = byDate.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return holidays;
  }

  String _normalizeDate(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
