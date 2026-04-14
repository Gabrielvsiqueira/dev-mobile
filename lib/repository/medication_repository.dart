import '../model/medication.dart';

class MedicationRepository {
  static final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Losartana',
      dosage: '50mg · 1 comprimido',
      schedules: [
        MedicationSchedule(
          id: 's1',
          medicationId: '1',
          scheduledTime: '08:00',
          recurrenceType: RecurrenceType.daily,
          status: MedicationStatus.taken,
        ),
      ],
    ),
    Medication(
      id: '2',
      name: 'Metformina',
      dosage: '500mg · 1 comprimido',
      schedules: [
        MedicationSchedule(
          id: 's2',
          medicationId: '2',
          scheduledTime: '12:00',
          recurrenceType: RecurrenceType.daily,
          status: MedicationStatus.pending,
        ),
      ],
    ),
    Medication(
      id: '3',
      name: 'Atenolol',
      dosage: '25mg · 1 comprimido',
      schedules: [
        MedicationSchedule(
          id: 's3',
          medicationId: '3',
          scheduledTime: '20:00',
          recurrenceType: RecurrenceType.daily,
          status: MedicationStatus.upcoming,
        ),
      ],
    ),
    Medication(
      id: '4',
      name: 'Vitamina D',
      dosage: '1000UI · 1 cápsula',
      schedules: [
        MedicationSchedule(
          id: 's4',
          medicationId: '4',
          scheduledTime: '08:00',
          recurrenceType: RecurrenceType.weekly,
          weekDays: ['mon', 'wed', 'fri'],
          status: MedicationStatus.taken,
        ),
      ],
    ),
    Medication(
      id: '5',
      name: 'Omeprazol',
      dosage: '20mg · 1 cápsula',
      schedules: [
        MedicationSchedule(
          id: 's5',
          medicationId: '5',
          scheduledTime: '07:00',
          recurrenceType: RecurrenceType.interval,
          intervalHours: 12,
          status: MedicationStatus.taken,
        ),
        MedicationSchedule(
          id: 's5b',
          medicationId: '5',
          scheduledTime: '19:00',
          recurrenceType: RecurrenceType.interval,
          intervalHours: 12,
          status: MedicationStatus.upcoming,
        ),
      ],
    ),
  ];

  Future<List<Medication>> getMedicationsForToday() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_medications);
  }

  Future<List<Medication>> getMedicationsForDay(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final weekday = _weekdayKey(date.weekday);
    return _medications.where((med) {
      return med.schedules.any((s) {
        if (!s.active) return false;
        if (s.recurrenceType == RecurrenceType.daily) return true;
        if (s.recurrenceType == RecurrenceType.interval) return true;
        if (s.recurrenceType == RecurrenceType.weekly) {
          return s.weekDays?.contains(weekday) ?? false;
        }
        return false;
      });
    }).toList();
  }

  Future<void> addMedication(Medication medication) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _medications.add(medication);
  }

  Future<void> removeMedication(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _medications.removeWhere((m) => m.id == id);
  }

  Future<void> updateMedication(Medication updatedMedication) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _medications.indexWhere((m) => m.id == updatedMedication.id);

    if (index != -1) {
      _medications[index] = updatedMedication;
    }
  }

  Future<void> resetToSeedData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _medications
      ..clear()
      ..addAll([
        Medication(
          id: '1',
          name: 'Losartana',
          dosage: '50mg · 1 comprimido',
          schedules: [
            MedicationSchedule(
              id: 's1',
              medicationId: '1',
              scheduledTime: '08:00',
              recurrenceType: RecurrenceType.daily,
              status: MedicationStatus.taken,
            ),
          ],
        ),
        Medication(
          id: '2',
          name: 'Metformina',
          dosage: '500mg · 1 comprimido',
          schedules: [
            MedicationSchedule(
              id: 's2',
              medicationId: '2',
              scheduledTime: '12:00',
              recurrenceType: RecurrenceType.daily,
              status: MedicationStatus.pending,
            ),
          ],
        ),
        Medication(
          id: '3',
          name: 'Atenolol',
          dosage: '25mg · 1 comprimido',
          schedules: [
            MedicationSchedule(
              id: 's3',
              medicationId: '3',
              scheduledTime: '20:00',
              recurrenceType: RecurrenceType.daily,
              status: MedicationStatus.upcoming,
            ),
          ],
        ),
        Medication(
          id: '4',
          name: 'Vitamina D',
          dosage: '1000UI · 1 cápsula',
          schedules: [
            MedicationSchedule(
              id: 's4',
              medicationId: '4',
              scheduledTime: '08:00',
              recurrenceType: RecurrenceType.weekly,
              weekDays: ['mon', 'wed', 'fri'],
              status: MedicationStatus.taken,
            ),
          ],
        ),
        Medication(
          id: '5',
          name: 'Omeprazol',
          dosage: '20mg · 1 cápsula',
          schedules: [
            MedicationSchedule(
              id: 's5',
              medicationId: '5',
              scheduledTime: '07:00',
              recurrenceType: RecurrenceType.interval,
              intervalHours: 12,
              status: MedicationStatus.taken,
            ),
            MedicationSchedule(
              id: 's5b',
              medicationId: '5',
              scheduledTime: '19:00',
              recurrenceType: RecurrenceType.interval,
              intervalHours: 12,
              status: MedicationStatus.upcoming,
            ),
          ],
        ),
      ]);
  }

  Future<void> updateStatus(String scheduleId, MedicationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final med in _medications) {
      for (final schedule in med.schedules) {
        if (schedule.id == scheduleId) {
          schedule.status = status;
          return;
        }
      }
    }
  }

  String _weekdayKey(int weekday) {
    const keys = {
      1: 'mon',
      2: 'tue',
      3: 'wed',
      4: 'thu',
      5: 'fri',
      6: 'sat',
      7: 'sun',
    };
    return keys[weekday] ?? 'mon';
  }
}
