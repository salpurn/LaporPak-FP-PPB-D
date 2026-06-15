import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/public_holiday.dart';
import 'package:laporpak_fp/core/services/holiday_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final HolidayService holidayService;

  const HolidayCalendarDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.holidayService,
  });

  @override
  State<HolidayCalendarDialog> createState() => _HolidayCalendarDialogState();
}

class _HolidayCalendarDialogState extends State<HolidayCalendarDialog> {
  final Map<int, List<PublicHoliday>> _holidaysByYear = {};
  final Set<int> _loadingYears = {};
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusedDay = _dateOnly(widget.initialDate);
    _selectedDay = _focusedDay;
    _loadHolidays(_focusedDay.year);
  }

  Future<void> _loadHolidays(int year) async {
    if (_holidaysByYear.containsKey(year) || _loadingYears.contains(year)) {
      return;
    }

    setState(() {
      _loadingYears.add(year);
      _errorText = null;
    });

    try {
      final holidays = await widget.holidayService.fetchHolidays(year);
      if (!mounted) return;
      setState(() {
        _holidaysByYear[year] = holidays;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Gagal memuat tanggal merah. Coba buka kalender lagi.';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingYears.remove(year));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedHoliday = _holidayFor(_selectedDay);
    final isLoading = _loadingYears.contains(_focusedDay.year);

    return AlertDialog(
      title: const Text('Pilih deadline'),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar<PublicHoliday>(
              firstDay: _dateOnly(widget.firstDate),
              lastDay: _dateOnly(widget.lastDate),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              eventLoader: (day) {
                final holiday = _holidayFor(day);
                return holiday == null ? const [] : [holiday];
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = _dateOnly(selectedDay);
                  _focusedDay = _dateOnly(focusedDay);
                });
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = _dateOnly(focusedDay));
                _loadHolidays(focusedDay.year);
              },
              enabledDayPredicate: (day) {
                final date = _dateOnly(day);
                return !date.isBefore(_dateOnly(widget.firstDate)) &&
                    !date.isAfter(_dateOnly(widget.lastDate));
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                ),
                holidayTextStyle: TextStyle(color: Colors.red.shade700),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                selectedDecoration: BoxDecoration(
                  color: selectedHoliday == null
                      ? Theme.of(context).colorScheme.primary
                      : Colors.red.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _holidayFor(day) == null ? null : _HolidayDayCell(day: day);
                },
                disabledBuilder: (context, day, focusedDay) {
                  return _holidayFor(day) == null
                      ? null
                      : _HolidayDayCell(day: day, isDisabled: true);
                },
                outsideBuilder: (context, day, focusedDay) {
                  return _holidayFor(day) == null
                      ? null
                      : _HolidayDayCell(day: day, isOutside: true);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _HolidayDayCell(
                    day: day,
                    isToday: true,
                    isHoliday: _holidayFor(day) != null,
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final isHoliday = _holidayFor(day) != null;
                  return _HolidayDayCell(
                    day: day,
                    isSelected: true,
                    isHoliday: isHoliday,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            const SizedBox(height: 10),
            _CalendarMessage(
              holiday: selectedHoliday,
              errorText: _errorText,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: selectedHoliday == null && !isLoading && _errorText == null
              ? () => Navigator.of(context).pop(_selectedDay)
              : null,
          child: const Text('Pilih'),
        ),
      ],
    );
  }

  PublicHoliday? _holidayFor(DateTime day) {
    final normalized = _normalizeDate(day);
    for (final holiday in _holidaysByYear[day.year] ?? const <PublicHoliday>[]) {
      if (holiday.date == normalized) return holiday;
    }
    return null;
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _normalizeDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _HolidayDayCell extends StatelessWidget {
  final DateTime day;
  final bool isDisabled;
  final bool isOutside;
  final bool isToday;
  final bool isSelected;
  final bool isHoliday;

  const _HolidayDayCell({
    required this.day,
    this.isDisabled = false,
    this.isOutside = false,
    this.isToday = false,
    this.isSelected = false,
    this.isHoliday = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isHoliday ? Colors.red.shade700 : theme.colorScheme.primary;
    final foregroundColor = isSelected ? Colors.white : baseColor;
    final opacity = isDisabled || isOutside ? 0.42 : 1.0;

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor
              : isToday
                  ? baseColor.withValues(alpha: 0.14)
                  : Colors.transparent,
          shape: BoxShape.circle,
          border: isHoliday && !isSelected
              ? Border.all(color: Colors.red.shade200)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: foregroundColor.withValues(alpha: opacity),
            fontWeight: isHoliday || isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _CalendarMessage extends StatelessWidget {
  final PublicHoliday? holiday;
  final String? errorText;

  const _CalendarMessage({required this.holiday, required this.errorText});

  @override
  Widget build(BuildContext context) {
    if (errorText != null) {
      return _MessageBox(
        icon: Icons.error_outline,
        color: Colors.red,
        text: errorText!,
      );
    }

    if (holiday != null) {
      return _MessageBox(
        icon: Icons.event_busy_outlined,
        color: Colors.red,
        text: '${holiday!.localName} adalah tanggal merah dan tidak bisa dipilih.',
      );
    }

    return _MessageBox(
      icon: Icons.info_outline,
      color: Theme.of(context).colorScheme.primary,
      text: 'Tanggal bertanda merah adalah hari libur nasional.',
    );
  }
}

class _MessageBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _MessageBox({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
