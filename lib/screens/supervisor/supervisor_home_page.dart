// STUB â€” replace with Module B implementation. Do not change filename or class name.
import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/public_holiday.dart';
import 'package:laporpak_fp/core/services/holiday_service.dart';

class SupervisorHomePage extends StatelessWidget {
  final AppUser user;
  static final HolidayService holidayService = NagerDateHolidayService();

  const SupervisorHomePage({super.key, required this.user});

  Future<void> _checkTodayHoliday() async {
    final isHoliday = await holidayService.isPublicHoliday(DateTime.now());
    debugPrint('Hari ini holiday? $isHoliday');
  }

  Future<List<PublicHoliday>> _loadHolidays() async {
    return holidayService.fetchHolidays(DateTime.now().year);
  }

  @override
  Widget build(BuildContext context) {
    _checkTodayHoliday();
    return const Center(
      child: Text('Module B â€” Supervisor (built by teammate B)'),
    );
  }
}
