import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../repository/medication_repository.dart';
import '../routes/app_router.dart';
import '../viewmodels/profile_view_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/stat_card.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({super.key, required this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileViewModel _viewModel;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(MedicationRepository());
    _nameController = TextEditingController(text: widget.userName);
    _phoneController = TextEditingController(text: AppSession.userPhone);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    _viewModel.toggleEdit();
    if (_viewModel.isEditing) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _nameFocus.requestFocus(),
      );
    }
  }

  void _saveEdit() {
    AppSession.userName = _nameController.text.trim();
    AppSession.userPhone = _phoneController.text.trim();
    _viewModel.saveEdit();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dados salvos!'),
        backgroundColor: _primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair do app?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _darkPurple,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Você voltará para a tela de login. Seus remédios continuarão salvos.',
          style: TextStyle(color: Color(0xFF8A7AAA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Limpar todos os remédios?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _darkPurple,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Os dados voltarão para os remédios de exemplo iniciais. Essa ação não pode ser desfeita.',
          style: TextStyle(color: Color(0xFF8A7AAA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _viewModel.resetData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Dados resetados para o exemplo inicial.',
                  ),
                  backgroundColor: const Color(0xFFC62828),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Limpar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
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
                      _buildAvatarCard(),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildDataCard(),
                      const SizedBox(height: 16),
                      _buildActionsCard(),
                      const SizedBox(height: 16),
                      _buildDangerCard(),
                    ],
                  ),
                ),
              ),
              AppBottomNav(activeTab: AppTab.profile),
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
          color: _primaryPurple,
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meu Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Suas informações pessoais',
                    style: TextStyle(
                      color: Color(0xFFD4C5F5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_viewModel.isEditing)
                GestureDetector(
                  onTap: _saveEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
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

  Widget _buildAvatarCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF5A3E9E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.elderly_woman_rounded,
              color: Color(0xFFBFA8EE),
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty ? 'Nenê' : _nameController.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _darkPurple,
            ),
          ),
          if (_phoneController.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _phoneController.text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9B8EC4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.medication_rounded,
            value: '${_viewModel.medicationCount}',
            label: 'Remédios\ncadastrados',
            color: _primaryPurple,
            bg: _lightPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.notifications_active_rounded,
            value: '${_viewModel.medicationCount}',
            label: 'Lembretes\nhoje',
            color: const Color(0xFF2E7D32),
            bg: const Color(0xFFE8F5E9),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dados pessoais',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryPurple,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: _viewModel.isEditing ? _saveEdit : _toggleEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _viewModel.isEditing ? 'Salvar' : 'Editar',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _primaryPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _lightPurple, height: 1, thickness: 1),
          _buildDataRow(
            label: 'Nome',
            controller: _nameController,
            focusNode: _nameFocus,
            hint: 'Seu nome',
            inputType: TextInputType.name,
          ),
          Divider(
            color: _lightPurple,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildDataRow(
            label: 'Telefone',
            controller: _phoneController,
            focusNode: _phoneFocus,
            hint: '(44) 99999-9999',
            inputType: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneFormatter(),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required TextInputType inputType,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9B8EC4),
              ),
            ),
          ),
          Expanded(
            child: _viewModel.isEditing
                ? TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: inputType,
                    inputFormatters: formatters,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _darkPurple,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFFC0B0E0),
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: controller.text.isEmpty
                          ? const Color(0xFFC0B0E0)
                          : _darkPurple,
                    ),
                  ),
          ),
          if (_viewModel.isEditing)
            const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFBFA8EE)),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.medication_rounded,
            label: 'Gerenciar remédios',
            onTap: () => context.go(AppRoutes.home),
          ),
          Divider(
            color: _lightPurple,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildActionRow(
            icon: Icons.calendar_month_rounded,
            label: 'Ver calendário',
            onTap: () => context.go(AppRoutes.calendar),
          ),
          Divider(
            color: _lightPurple,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildActionRow(
            icon: Icons.emergency_rounded,
            label: 'Contato de emergência',
            onTap: () => context.go(AppRoutes.emergency),
            danger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFC62828) : _darkPurple;
    final bg = danger ? const Color(0xFFFFEBEE) : _lightPurple;
    final iconColor = danger ? const Color(0xFFC62828) : _primaryPurple;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: danger
                  ? const Color(0xFFEF9A9A)
                  : const Color(0xFFBFA8EE),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      child: Column(
        children: [
          _buildDangerRow(
            icon: Icons.refresh_rounded,
            label: 'Resetar para dados de exemplo',
            color: const Color(0xFFE65100),
            bg: const Color(0xFFFFF3E0),
            onTap: _confirmReset,
          ),
          Divider(
            color: _lightPurple,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildDangerRow(
            icon: Icons.logout_rounded,
            label: 'Sair do app',
            color: const Color(0xFFC62828),
            bg: const Color(0xFFFFEBEE),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerRow({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
