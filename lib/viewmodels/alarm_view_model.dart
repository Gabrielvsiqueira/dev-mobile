import 'dart:async';
import 'package:flutter/foundation.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';

class AlarmViewModel extends ChangeNotifier {
  final MedicationRepository _repository;
  final Medication medication;
  final MedicationSchedule schedule;

  bool _isDone = false;
  bool _isSnoozed = false;
  int _snoozeSecondsLeft = 0;
  Timer? _snoozeTimer;

  bool get isDone => _isDone;
  bool get isSnoozed => _isSnoozed;
  int get snoozeSecondsLeft => _snoozeSecondsLeft;

  AlarmViewModel(
    this._repository, {
    required this.medication,
    required this.schedule,
  });

  Future<void> takeMedication() async {
    _isDone = true;
    _snoozeTimer?.cancel();
    notifyListeners();
    await _repository.updateStatus(schedule.id, MedicationStatus.taken);
  }

  void snooze() {
    if (_isSnoozed) return;
    _isSnoozed = true;
    _snoozeSecondsLeft = 5 * 60;
    notifyListeners();

    _snoozeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _snoozeSecondsLeft--;
      if (_snoozeSecondsLeft <= 0) {
        timer.cancel();
        _isSnoozed = false;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _snoozeTimer?.cancel();
    super.dispose();
  }

  String get snoozeLabel {
    if (!_isSnoozed) return 'Lembrar em 5 minutos';
    final min = _snoozeSecondsLeft ~/ 60;
    final sec = _snoozeSecondsLeft % 60;
    return 'Lembrete em ${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get recurrenceLabel {
    switch (schedule.recurrenceType) {
      case RecurrenceType.daily:
        return 'Todo dia';
      case RecurrenceType.weekly:
        final days = schedule.weekDays ?? [];
        const map = {
          'mon': 'Seg',
          'tue': 'Ter',
          'wed': 'Qua',
          'thu': 'Qui',
          'fri': 'Sex',
          'sat': 'Sáb',
          'sun': 'Dom',
        };
        return days.map((d) => map[d] ?? d).join(', ');
      case RecurrenceType.interval:
        return 'A cada ${schedule.intervalHours}h';
    }
  }
}
