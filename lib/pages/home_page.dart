import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';
import '../routes/app_router.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, this.userName = 'Dona Nenê'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = MedicationRepository();
  String get _userName => widget.userName;

  DateTime _selectedDate = DateTime.now();
  List<Medication> _medications = [];
  bool _isLoading = true;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    final meds = await _repository.getMedicationsForDay(_selectedDate);
    setState(() {
      _medications = meds;
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          _buildBottomNav(),
        ],
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
                      _greeting(),
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
                    color: const Color(0xFF5A3E9E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBFA8EE),
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFFBFA8EE),
                    size: 28,
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
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(5, (i) => startOfWeek.add(Duration(days: i)));
    const dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

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
              final isSelected = _isSameDay(day, _selectedDate);
              return GestureDetector(
                onTap: () => _onDaySelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _primaryPurple : const Color(0xFFEAE4F7),
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
                          color: isSelected ? const Color(0xFFD4C5F5) : const Color(0xFF9B8EC4),
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
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : const Color(0xFFBFA8EE),
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
          ..._medications.map(
            (med) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_rounded,
                    color: _primaryPurple, size: 22),
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
                style: const TextStyle(
                  color: Color(0xFF8A7AAA),
                  fontSize: 12,
                ),
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: _primaryPurple),
            )
          else if (_medications.isEmpty)
            _buildEmptyState()
          else
            ...(_medications
                .expand((med) => med.schedules.map((s) => (med, s)))
                .toList()
              ..sort((a, b) => a.$2.scheduledTime.compareTo(b.$2.scheduledTime)))
                .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => context.push(
                        AppRoutes.alarm,
                        extra: AlarmArgs(
                          medication: entry.$1,
                          schedule: entry.$2,
                        ),
                      ),
                      child: _buildMedicationCard(entry.$1, entry.$2),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication med, MedicationSchedule schedule) {
    final config = _statusConfig(schedule.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: config.borderColor,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: config.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.medication_rounded, color: config.iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _darkPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  med.dosage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A7AAA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: config.timeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  schedule.scheduledTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: config.timeColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: config.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  config.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: config.badgeText,
                  ),
                ),
              ),
            ],
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
              if (changed == true) _loadMedications();
            },
          ),
          const SizedBox(height: 10),
          _buildButton(
            label: 'Editar medicamentos',
            icon: Icons.edit_outlined,
            isPrimary: false,
            onTap: () async {
              if (_medications.isEmpty) return;
              final selected = await _showPickMedicationSheet();
              if (selected == null) return;
              final changed = await context.push<bool>(
                AppRoutes.wizardEdit,
                extra: selected,
              );
              if (changed == true) _loadMedications();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAE4F7), width: 1.5)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 24,
        right: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Início',
            isActive: true,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendário',
            onTap: () => context.go(AppRoutes.calendar),
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Perfil',
            onTap: () => context.go(AppRoutes.profile, extra: _userName),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24,
              color: isActive ? _primaryPurple : const Color(0xFFBFA8EE)),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? _primaryPurple : const Color(0xFFBFA8EE),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  _StatusConfig _statusConfig(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return _StatusConfig(
          label: 'Tomado',
          borderColor: const Color(0xFFEAE4F7),
          iconBg: const Color(0xFFEAE4F7),
          iconColor: _primaryPurple,
          timeBg: const Color(0xFFEAE4F7),
          timeColor: _primaryPurple,
          badgeBg: const Color(0xFFE8F5E9),
          badgeText: const Color(0xFF2E7D32),
        );
      case MedicationStatus.pending:
        return _StatusConfig(
          label: 'Pendente',
          borderColor: const Color(0xFFFFE0B2),
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE65100),
          timeBg: const Color(0xFFFFF3E0),
          timeColor: const Color(0xFFE65100),
          badgeBg: const Color(0xFFFFF3E0),
          badgeText: const Color(0xFFE65100),
        );
      case MedicationStatus.upcoming:
        return _StatusConfig(
          label: 'Mais tarde',
          borderColor: const Color(0xFFEAE4F7),
          iconBg: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
          timeBg: const Color(0xFFEAE4F7),
          timeColor: _primaryPurple,
          badgeBg: const Color(0xFFF3F0FA),
          badgeText: _primaryPurple,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color borderColor;
  final Color iconBg;
  final Color iconColor;
  final Color timeBg;
  final Color timeColor;
  final Color badgeBg;
  final Color badgeText;

  const _StatusConfig({
    required this.label,
    required this.borderColor,
    required this.iconBg,
    required this.iconColor,
    required this.timeBg,
    required this.timeColor,
    required this.badgeBg,
    required this.badgeText,
  });
}