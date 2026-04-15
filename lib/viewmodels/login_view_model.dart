import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _nameError = false;

  bool get isLoading => _isLoading;
  bool get nameError => _nameError;

  bool validate(String name) {
    if (name.trim().isEmpty) {
      _nameError = true;
      notifyListeners();
      return false;
    }
    _nameError = false;
    notifyListeners();
    return true;
  }

  void clearNameError() {
    if (_nameError) {
      _nameError = false;
      notifyListeners();
    }
  }

  Future<void> login() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
  }
}
