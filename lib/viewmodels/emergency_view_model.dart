import 'package:flutter/foundation.dart';

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });
}

class EmergencyViewModel extends ChangeNotifier {
  final List<EmergencyContact> _contacts = [
    const EmergencyContact(
      name: 'Maria Aparecida',
      relationship: 'Filha',
      phone: '(44) 99111-2222',
    ),
    const EmergencyContact(
      name: 'João Carlos',
      relationship: 'Genro',
      phone: '(44) 99333-4444',
    ),
  ];

  bool _isAdding = false;

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  bool get isAdding => _isAdding;

  void openAddForm() {
    _isAdding = true;
    notifyListeners();
  }

  void cancelAddForm() {
    _isAdding = false;
    notifyListeners();
  }

  void addContact(String name, String relationship, String phone) {
    _contacts.add(EmergencyContact(
      name: name,
      relationship: relationship.isEmpty ? 'Contato' : relationship,
      phone: phone,
    ));
    _isAdding = false;
    notifyListeners();
  }

  void removeContact(int index) {
    _contacts.removeAt(index);
    notifyListeners();
  }

  String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}
