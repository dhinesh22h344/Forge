import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/habits/data/models/habit_reminder_model.dart';
import 'package:forge/features/habits/domain/repositories/habit_repository.dart';

void main() {
  group('HabitReminderModel', () {
    test('fromJson parses localTime, daysOfWeek, and active', () {
      final model = HabitReminderModel.fromJson(
        {'id': 'r1', 'localTime': '07:30:00', 'daysOfWeek': ['MON', 'WED'], 'active': true},
        habitId: 'h1',
      );

      expect(model.id, 'r1');
      expect(model.habitId, 'h1');
      expect(model.hour, 7);
      expect(model.minute, 30);
      expect(model.daysOfWeek, ['MON', 'WED']);
      expect(model.active, isTrue);
    });

    test('fromJson defaults an absent daysOfWeek to empty (every day)', () {
      final model = HabitReminderModel.fromJson(
        {'id': 'r1', 'localTime': '20:00:00', 'daysOfWeek': null, 'active': false},
        habitId: 'h1',
      );

      expect(model.daysOfWeek, isEmpty);
    });

    test('draftToJson formats hour/minute as zero-padded HH:mm:00', () {
      final json = HabitReminderModel.draftToJson(
        const HabitReminderDraft(hour: 7, minute: 5, daysOfWeek: ['FRI'], active: true),
      );

      expect(json['localTime'], '07:05:00');
      expect(json['daysOfWeek'], ['FRI']);
      expect(json['active'], isTrue);
    });
  });
}
