import 'package:flutter/foundation.dart';
import '../repository/medication_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final MedicationRepository _repository;

  int _medicationCount = 0;
  bool _isEditing = false;

  int get medicationCount => _medicationCount;
  bool get isEditing => _isEditing;

  ProfileViewModel(this._repository) {
    _loadCount();
  }

  Future<void> _loadCount() async {
    final meds = await _repository.getMedicationsForToday();
    _medicationCount = meds.length;
    notifyListeners();
  }

  void toggleEdit() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  void saveEdit() {
    _isEditing = false;
    notifyListeners();
  }

  Future<void> resetData() async {
    await _repository.resetToSeedData();
    await _loadCount();
  }
}
