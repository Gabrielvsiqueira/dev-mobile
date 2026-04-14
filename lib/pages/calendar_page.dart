import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';
import '../routes/app_router.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _repository = MedicationRepository();

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Medication> _dayMedications = [];
  bool _isLoading = true;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  static const _weekLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  static const _monthNames = [
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

  @override
  void initState() {
    super.initState();
    _loadDay(_selectedDay);
  }

  Future<void> _loadDay(DateTime date) async {
    setState(() => _isLoading = true);
    final meds = await _repository.getMedicationsForDay(date);
    setState(() {
      _selectedDay = date;
      _dayMedications = meds;
      _isLoading = false;
    });
  }

  void _prevMonth() => setState(
    () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1),
  );

  void _nextMonth() => setState(
    () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1),
  );

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  /// Gera todas as células do mês (incluindo dias do mês anterior/próximo
  /// para completar as semanas).
  List<DateTime?> _buildCalendarCells() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // domingo = 0

    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= lastDay.day; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 24),
                  _buildDaySection(),
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
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calendário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Histórico e agenda de remédios',
                style: TextStyle(
                  color: Color(0xFFD4C5F5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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

  Widget _buildCalendar() {
    final cells = _buildCalendarCells();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Navegação do mês
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: _primaryPurple,
                    size: 22,
                  ),
                ),
              ),
              Text(
                '${_monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _darkPurple,
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: _primaryPurple,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Labels dos dias da semana
          Row(
            children: _weekLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B8EC4),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Grid dos dias
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final day = cells[index];
              if (day == null) return const SizedBox.shrink();
              final isSelected = _isSameDay(day, _selectedDay);
              final isToday = _isToday(day);
              final isCurrentMonth = day.month == _focusedMonth.month;

              return GestureDetector(
                onTap: () => _loadDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primaryPurple
                        : isToday
                        ? _lightPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? _primaryPurple
                              : isCurrentMonth
                              ? _darkPurple
                              : const Color(0xFFCCBBEE),
                        ),
                      ),
                      // Ponto indicador de remédio
                      if (isCurrentMonth)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white.withOpacity(0.7)
                                : _primaryPurple.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection() {
    final now = DateTime.now();
    final isToday = _isSameDay(_selectedDay, now);
    final isPast = _selectedDay.isBefore(
      DateTime(now.year, now.month, now.day),
    );
    final dayLabel = isToday
        ? 'Hoje'
        : '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dayLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryPurple,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            if (isPast && !isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Histórico',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _primaryPurple,
                  ),
                ),
              )
            else if (!isPast && !isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Agendado',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: _primaryPurple),
            ),
          )
        else if (_dayMedications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _lightPurple, width: 1.5),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFFBFA8EE),
                  size: 36,
                ),
                SizedBox(height: 8),
                Text(
                  'Nenhum remédio neste dia',
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
          ...(_dayMedications
                  .expand((med) => med.schedules.map((s) => (med, s)))
                  .toList()
                ..sort(
                  (a, b) => a.$2.scheduledTime.compareTo(b.$2.scheduledTime),
                ))
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildHistoryCard(entry.$1, entry.$2, isPast),
                ),
              ),
      ],
    );
  }

  Widget _buildHistoryCard(
    Medication med,
    MedicationSchedule schedule,
    bool isPast,
  ) {
    final isTaken = schedule.status == MedicationStatus.taken;
    final isPending = schedule.status == MedicationStatus.pending;

    Color borderColor;
    Color iconBg;
    Color iconColor;
    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    IconData statusIcon;

    if (isPast) {
      if (isTaken) {
        borderColor = const Color(0xFFE8F5E9);
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
        badgeBg = const Color(0xFFE8F5E9);
        badgeText = const Color(0xFF2E7D32);
        badgeLabel = 'Tomado';
        statusIcon = Icons.check_rounded;
      } else {
        borderColor = const Color(0xFFFFEBEE);
        iconBg = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFC62828);
        badgeBg = const Color(0xFFFFEBEE);
        badgeText = const Color(0xFFC62828);
        badgeLabel = 'Perdido';
        statusIcon = Icons.close_rounded;
      }
    } else if (isTaken) {
      borderColor = const Color(0xFFE8F5E9);
      iconBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = const Color(0xFF2E7D32);
      badgeLabel = 'Tomado';
      statusIcon = Icons.check_rounded;
    } else if (isPending) {
      borderColor = const Color(0xFFFFE0B2);
      iconBg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      badgeBg = const Color(0xFFFFF3E0);
      badgeText = const Color(0xFFE65100);
      badgeLabel = 'Pendente';
      statusIcon = Icons.access_time_rounded;
    } else {
      borderColor = _lightPurple;
      iconBg = _lightPurple;
      iconColor = _primaryPurple;
      badgeBg = const Color(0xFFF3F0FA);
      badgeText = _primaryPurple;
      badgeLabel = 'Agendado';
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _darkPurple,
                  ),
                ),
                Text(
                  med.dosage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A7AAA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _lightPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  schedule.scheduledTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
        ],
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
            onTap: () => context.go(AppRoutes.home),
          ),
          _buildNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendário',
            isActive: true,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Perfil',
            onTap: () => context.go(AppRoutes.profile),
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
          Icon(
            icon,
            size: 24,
            color: isActive ? _primaryPurple : const Color(0xFFBFA8EE),
          ),
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
}
