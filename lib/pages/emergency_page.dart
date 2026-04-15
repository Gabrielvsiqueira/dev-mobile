import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../viewmodels/emergency_view_model.dart';
import '../widgets/contact_card.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late EmergencyViewModel _viewModel;

  final _nameController = TextEditingController();
  final _relController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  static const _dangerRed = Color(0xFFC62828);
  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  @override
  void initState() {
    super.initState();
    _viewModel = EmergencyViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _relController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _callPhone(String phone) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ligando para $phone...'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _callSamu() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ligando para o SAMU · 192...'),
        backgroundColor: _dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddForm() {
    _viewModel.openAddForm();
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _nameFocus.requestFocus(),
    );
  }

  void _cancelAddForm() {
    _viewModel.cancelAddForm();
    _nameController.clear();
    _relController.clear();
    _phoneController.clear();
    FocusScope.of(context).unfocus();
  }

  void _saveContact() {
    final name = _nameController.text.trim();
    final rel = _relController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    _viewModel.addContact(name, rel, phone);

    _nameController.clear();
    _relController.clear();
    _phoneController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name adicionado!'),
        backgroundColor: _primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeContact(int index) {
    final name = _viewModel.contacts[index].name;
    _viewModel.removeContact(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removido.'),
        backgroundColor: const Color(0xFF5F5E5A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: _softBg,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    children: [
                      _buildSamuButton(),
                      const SizedBox(height: 24),
                      _buildContactsList(),
                      const SizedBox(height: 16),
                      if (_viewModel.isAdding) _buildAddForm(),
                      if (!_viewModel.isAdding) _buildAddButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          color: _dangerRed,
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFFFFCDD2),
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergência',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Contatos para situações de urgência',
                      style: TextStyle(
                        color: Color(0xFFFFCDD2),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              color: _softBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSamuButton() {
    return GestureDetector(
      onTap: _callSamu,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: _dangerRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ligar para o SAMU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Serviço de urgência gratuito',
                    style: TextStyle(
                      color: Color(0xFFFFCDD2),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '192',
                style: TextStyle(
                  color: _dangerRed,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    final contacts = _viewModel.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MEUS CONTATOS',
          style: TextStyle(
            color: _primaryPurple,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        if (contacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _lightPurple, width: 1.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  color: Colors.grey.shade300,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nenhum contato adicionado ainda',
                  style: TextStyle(
                    color: Color(0xFFB0A0CC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(contacts.length, (index) {
            final contact = contacts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ContactCard(
                name: contact.name,
                relationship: contact.relationship,
                phone: contact.phone,
                initials: _viewModel.initials(contact.name),
                onCall: () => _callPhone(contact.phone),
                onDismiss: () => _removeContact(index),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _openAddForm,
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: const Text('Adicionar contato'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryPurple,
          side: const BorderSide(color: Color(0xFFEAE4F7), width: 1.5),
          backgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOVO CONTATO',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          _buildFormField(
            label: 'Nome completo',
            hint: 'Ex: Maria Aparecida',
            controller: _nameController,
            focusNode: _nameFocus,
            inputType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          _buildFormField(
            label: 'Parentesco',
            hint: 'Ex: Filha, Neto, Cuidador...',
            controller: _relController,
            inputType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          _buildFormField(
            label: 'Telefone',
            hint: '(44) 99999-9999',
            controller: _phoneController,
            inputType: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneFormatter(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelAddForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9B8EC4),
                    side: const BorderSide(
                      color: Color(0xFFEAE4F7),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    FocusNode? focusNode,
    required TextInputType inputType,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9B8EC4),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: inputType,
          inputFormatters: formatters,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _darkPurple,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFC0B0E0),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F4F0),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEAE4F7),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEAE4F7),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buf.write('(');
      if (i == 2) buf.write(') ');
      if (i == 7) buf.write('-');
      buf.write(digits[i]);
    }
    final f = buf.toString();
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}
