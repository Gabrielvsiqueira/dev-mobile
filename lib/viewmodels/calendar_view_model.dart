import 'package:flutter/foundation.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final MedicationRepository _repository;

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Medication> _dayMedications = [];
  bool _isLoading = false;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDay => _selectedDay;
  List<Medication> get dayMedications => _dayMedications;
  bool get isLoading => _isLoading;

  static const monthNames = [
    '',
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  CalendarViewModel(this._repository) {
    loadDay(_selectedDay);
  }

  Future<void> loadDay(DateTime date) async {
    _selectedDay = date;
    _isLoading = true;
    notifyListeners();
    _dayMedications = await _repository.getMedicationsForDay(date);
    _isLoading = false;
    notifyListeners();
  }

  void prevMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isToday(DateTime d) => isSameDay(d, DateTime.now());

  List<DateTime?> buildCalendarCells() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;

    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= lastDay.day; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }
}
