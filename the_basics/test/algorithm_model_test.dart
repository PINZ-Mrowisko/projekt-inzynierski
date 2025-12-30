import 'package:flutter_test/flutter_test.dart';

import 'package:the_basics/features/templates/models/algorithm_model.dart';

void main() {
  group('Worker', () {
    test('creates Worker with provided role', () {
      final worker = Worker(
        firstname: 'Jan',
        lastname: 'Kowalski',
        role: 'Manager',
      );

      expect(worker.firstname, 'Jan');
      expect(worker.lastname, 'Kowalski');
      expect(worker.role, 'Manager');
    });

    test('replaces default role with "Brak roli"', () {
      final worker = Worker(
        firstname: 'Anna',
        lastname: 'Nowak',
        role: 'default',
      );

      expect(worker.role, 'Brak roli');
    });

    test('creates Worker from JSON', () {
      final json = {
        'firstname': 'Piotr',
        'lastname': 'Zieliński',
        'role': 'Employee',
      };

      final worker = Worker.fromJson(json);

      expect(worker.firstname, 'Piotr');
      expect(worker.lastname, 'Zieliński');
      expect(worker.role, 'Employee');
    });
  });

  group('Shift', () {
    test('creates Shift from JSON with workers', () {
      final json = {
        'shift': 1,
        'workers': [
          {
            'firstname': 'Jan',
            'lastname': 'Kowalski',
            'role': 'default',
          },
          {
            'firstname': 'Anna',
            'lastname': 'Nowak',
            'role': 'Manager',
          },
        ],
      };

      final shift = Shift.fromJson(json);

      expect(shift.shift, 1);
      expect(shift.workers.length, 2);

      expect(shift.workers[0].firstname, 'Jan');
      expect(shift.workers[0].role, 'Brak roli');
      expect(shift.workers[1].role, 'Manager');
    });
  });

  group('DaySchedule', () {
    test('creates DaySchedule from JSON', () {
      final json = {
        'day': 1,
        'shifts': [
          {
            'shift': 1,
            'workers': [
              {
                'firstname': 'Jan',
                'lastname': 'Kowalski',
                'role': 'Employee',
              }
            ],
          }
        ],
      };

      final schedule = DaySchedule.fromJson(json);

      expect(schedule.day, 1);
      expect(schedule.shifts.length, 1);
      expect(schedule.shifts.first.shift, 1);
      expect(schedule.shifts.first.workers.first.firstname, 'Jan');
    });

    test('returns correct dayName for valid days', () {
      final monday = DaySchedule(day: 1, shifts: []);
      final sunday = DaySchedule(day: 7, shifts: []);

      expect(monday.dayName, 'Poniedziałek');
      expect(sunday.dayName, 'Niedziela');
    });

    test('returns "Nieznany dzień" for invalid day (0)', () {
      final schedule = DaySchedule(day: 0, shifts: []);

      expect(schedule.dayName, 'Nieznany dzień');
    });

    test('returns "Nieznany dzień" for invalid day (>7)', () {
      final schedule = DaySchedule(day: 8, shifts: []);

      expect(schedule.dayName, 'Nieznany dzień');
    });
  });
}
