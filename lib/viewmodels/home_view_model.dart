import 'package:flutter/foundation.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MedicationRepository _repository;

  DateTime _selectedDate = DateTime.now();
  List<Medication> _medications = [];
  List<Medication> _allMedications = [];
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<Medication> get medications => _medications;
  List<Medication> get allMedications => _allMedications;
  bool get isLoading => _isLoading;

  HomeViewModel(this._repository) {
    _load();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    notifyListeners();
    await _load();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    _medications = await _repository.getMedicationsForDay(_selectedDate);
    _allMedications = await _repository.getAllMedications();
    _isLoading = false;
    notifyListeners();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> get weekDays {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(5, (i) => startOfWeek.add(Duration(days: i)));
  }
}
