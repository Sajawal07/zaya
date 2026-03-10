import 'package:flutter_test/flutter_test.dart';
import 'package:zaya/features/pregnancy/domain/pregnancy_service.dart';

void main() {
  group('PregnancyService Tests', () {
    test('calculateProgress with recent start date', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 10)); // 1 week, 3 days
      
      final progress = PregnancyService.calculateProgress(lastPeriodDate: startDate);
      
      expect(progress['week'], 1);
      expect(progress['day'], 3);
    });

    test('calculateProgress with exactly 40 weeks', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 280));
      
      final progress = PregnancyService.calculateProgress(lastPeriodDate: startDate);
      
      expect(progress['week'], 40);
      expect(progress['day'], 0);
    });

    test('calculateProgress with future date should return 0', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 10));
      
      final progress = PregnancyService.calculateProgress(lastPeriodDate: futureDate);
      
      expect(progress['week'], 0);
      expect(progress['day'], 0);
    });

    test('calculateProgress with overdue date (e.g. 45 weeks) should cap at 42', () {
      final now = DateTime.now();
      final overdueDate = now.subtract(const Duration(days: 315)); // 45 weeks
      
      final progress = PregnancyService.calculateProgress(lastPeriodDate: overdueDate);
      
      expect(progress['week'], 42);
      expect(progress['day'], 0);
    });

    test('getWeekInfo should return correct emoji and size', () {
      final week12 = PregnancyService.getWeekInfo(12);
      expect(week12.babyEmoji, "🟣");
      expect(week12.babySizeComparison, "Plum");

      final week20 = PregnancyService.getWeekInfo(20);
      expect(week20.babyEmoji, "🍌");
      expect(week20.babySizeComparison, "Banana");
    });

    test('getWeekInfo should interpolate for undefined weeks', () {
      // Week 7 is not defined, should return info for Week 6 (closest <= 7)
      final week7 = PregnancyService.getWeekInfo(7);
      expect(week7.week, 6);
      expect(week7.babyEmoji, "🫛");
    });
  });
}
