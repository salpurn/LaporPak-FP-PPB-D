abstract class HolidayService {
  Future<bool> isPublicHoliday(DateTime date);
  Future<List<DateTime>> fetchHolidays(int year);
}
