import 'package:flutter/foundation.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';

class WizardViewModel extends ChangeNotifier {
  final MedicationRepository _repository;
  final Medication? initialMedication;

  static const int totalSteps = 4;

  int _currentStep = 0;
  String name = '';
  String dosage = '';
  List<String> selectedTimes = ['08:00'];
  RecurrenceType recurrenceType = RecurrenceType.daily;
  List<String> selectedWeekDays = [];
  int intervalHours = 8;

  bool get isEditing => initialMedication != null;
  int get currentStep => _currentStep;

  WizardViewModel(this._repository, {this.initialMedication}) {
    if (initialMedication != null) {
      _initFromMedication(initialMedication!);
    }
  }

  void _initFromMedication(Medication med) {
    name = med.name;
    dosage = med.dosage;
    if (med.schedules.isNotEmpty) {
      final s = med.schedules.first;
      recurrenceType = s.recurrenceType;
      selectedTimes = med.schedules.map((s) => s.scheduledTime).toList();
      selectedWeekDays = List.from(s.weekDays ?? []);
      intervalHours = s.intervalHours ?? 8;
    }
  }

  void goToStep(int step) {
    if (step < 0 || step >= totalSteps) return;
    _currentStep = step;
    notifyListeners();
  }

  bool canAdvance(int step) {
    switch (step) {
      case 0:
        return name.trim().isNotEmpty && dosage.trim().isNotEmpty;
      case 1:
        return selectedTimes.isNotEmpty;
      case 2:
        if (recurrenceType == RecurrenceType.weekly) {
          return selectedWeekDays.isNotEmpty;
        }
        return true;
      default:
        return true;
    }
  }

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateDosage(String value) {
    dosage = value;
    notifyListeners();
  }

  void toggleTime(String time) {
    if (selectedTimes.contains(time)) {
      if (selectedTimes.length > 1) selectedTimes.remove(time);
    } else {
      selectedTimes.add(time);
      selectedTimes.sort();
    }
    notifyListeners();
  }

  void setRecurrenceType(RecurrenceType type) {
    recurrenceType = type;
    notifyListeners();
  }

  void toggleWeekDay(String day) {
    if (selectedWeekDays.contains(day)) {
      selectedWeekDays.remove(day);
    } else {
      selectedWeekDays.add(day);
    }
    notifyListeners();
  }

  void setIntervalHours(int hours) {
    intervalHours = hours;
    notifyListeners();
  }

  Future<void> save() async {
    final id =
        initialMedication?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final schedules = selectedTimes.map((time) {
      return MedicationSchedule(
        id: '${id}_$time',
        medicationId: id,
        scheduledTime: time,
        recurrenceType: recurrenceType,
        weekDays: recurrenceType == RecurrenceType.weekly
            ? List.from(selectedWeekDays)
            : null,
        intervalHours: recurrenceType == RecurrenceType.interval
            ? intervalHours
            : null,
        status: MedicationStatus.upcoming,
      );
    }).toList();

    final medication = Medication(
      id: id,
      name: name.trim(),
      dosage: dosage.trim(),
      schedules: schedules,
    );

    if (isEditing) {
      await _repository.updateMedication(medication);
    } else {
      await _repository.addMedication(medication);
    }
  }

  Future<void> delete() async {
    if (initialMedication != null) {
      await _repository.removeMedication(initialMedication!.id);
    }
  }

  String get recurrenceLabel {
    const labels = {
      'mon': 'Seg',
      'tue': 'Ter',
      'wed': 'Qua',
      'thu': 'Qui',
      'fri': 'Sex',
      'sat': 'Sáb',
      'sun': 'Dom',
    };
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'Todo dia';
      case RecurrenceType.weekly:
        if (selectedWeekDays.isEmpty) return 'Dias da semana (nenhum selecionado)';
        return selectedWeekDays.map((d) => labels[d] ?? d).join(', ');
      case RecurrenceType.interval:
        return 'A cada ${intervalHours}h';
    }
  }
}
