// lib/core/models/public_holiday.dart
// Model yang merepresentasikan satu entri dari response Nager.Date API
// Endpoint: GET https://date.nager.at/api/v3/PublicHolidays/{year}/ID

class PublicHoliday {
  final String date;
  final String localName;
  final String name;

  const PublicHoliday({
    required this.date,
    required this.localName,
    required this.name,
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    return PublicHoliday(
      date: json['date'] as String,
      localName: json['localName'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'localName': localName,
        'name': name,
      };

  @override
  String toString() => 'PublicHoliday(date: $date, name: $name)';
}
