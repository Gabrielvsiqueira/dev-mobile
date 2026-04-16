enum MedicationStatus { taken, pending, upcoming }

enum RecurrenceType { daily, weekly, interval }

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String? audioUrl;
  final List<MedicationSchedule> schedules;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.audioUrl,
    required this.schedules,
  });
}

class MedicationSchedule {
  final String id;
  final String medicationId;
  final String scheduledTime;
  final RecurrenceType recurrenceType;
  final List<String>? weekDays;
  final int? intervalHours;
  final bool active;
  MedicationStatus status;

  MedicationSchedule({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    required this.recurrenceType,
    this.weekDays,
    this.intervalHours,
    this.active = true,
    this.status = MedicationStatus.upcoming,
  });
}
