import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';
import '../routes/app_router.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/medication_card.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, this.userName = 'Dona Nenê'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;

  String get _userName => widget.userName;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(MedicationRepository());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: _softBg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildDateStrip(),
                    const SizedBox(height: 20),
                    _buildMedicationsList(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            AppBottomNav(activeTab: AppTab.home),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          color: _primaryPurple,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viewModel.greeting,
                      style: const TextStyle(
                        color: Color(0xFFE8DFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_userName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBFA8EE),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/images/logo_v1_icone_app.png',
                      fit: BoxFit.cover,
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

  Widget _buildDateStrip() {
    final days = _viewModel.weekDays;
    const dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'ESTA SEMANA',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final isSelected = _viewModel.isSameDay(
                day,
                _viewModel.selectedDate,
              );
              return GestureDetector(
                onTap: () => _viewModel.selectDate(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? _primaryPurple
                          : const Color(0xFFEAE4F7),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFFD4C5F5)
                              : const Color(0xFF9B8EC4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : _darkPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFBFA8EE),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<Medication?> _showPickMedicationSheet() async {
    return showModalBottomSheet<Medication>(
      context: context,
      backgroundColor: _softBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4C5F5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Qual remédio editar?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _darkPurple,
            ),
          ),
          const SizedBox(height: 12),
          ..._viewModel.allMedications.map(
            (med) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: _primaryPurple,
                  size: 22,
                ),
              ),
              title: Text(
                med.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _darkPurple,
                ),
              ),
              subtitle: Text(
                med.dosage,
                style: const TextStyle(color: Color(0xFF8A7AAA), fontSize: 12),
              ),
              onTap: () => ctx.pop(med),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildMedicationsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REMÉDIOS DE HOJE',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          if (_viewModel.isLoading)
            const Center(
              child: CircularProgressIndicator(color: _primaryPurple),
            )
          else if (_viewModel.medications.isEmpty)
            _buildEmptyState()
          else
            ...(_viewModel.medications
                    .expand((med) => med.schedules.map((s) => (med, s)))
                    .toList()
                  ..sort(
                    (a, b) => a.$2.scheduledTime.compareTo(b.$2.scheduledTime),
                  ))
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MedicationCard(
                      medication: entry.$1,
                      schedule: entry.$2,
                      onTap: () => context.push(
                        AppRoutes.alarm,
                        extra: AlarmArgs(
                          medication: entry.$1,
                          schedule: entry.$2,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: const Text(
        'Nenhum remédio para este dia 🌸',
        style: TextStyle(
          color: Color(0xFFB0A0CC),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildButton(
            label: 'Adicionar medicamento',
            icon: Icons.add_circle_outline_rounded,
            isPrimary: true,
            onTap: () async {
              final changed = await context.push<bool>(AppRoutes.wizardAdd);
              if (changed == true) _viewModel.reload();
            },
          ),
          const SizedBox(height: 10),
          _buildButton(
            label: 'Editar medicamentos',
            icon: Icons.edit_outlined,
            isPrimary: false,
            onTap: () async {
              if (_viewModel.allMedications.isEmpty) return;
              final selected = await _showPickMedicationSheet();
              if (selected == null) return;
              final changed = await context.push<bool>(
                AppRoutes.wizardEdit,
                extra: selected,
              );
              if (changed == true) _viewModel.reload();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? _primaryPurple : _lightPurple,
          foregroundColor: isPrimary ? Colors.white : _darkPurple,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
