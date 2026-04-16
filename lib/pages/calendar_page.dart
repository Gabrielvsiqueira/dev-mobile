import 'package:flutter/material.dart';
import '../repository/medication_repository.dart';
import '../viewmodels/calendar_view_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/history_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarViewModel _viewModel;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  static const _weekLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarViewModel(MedicationRepository());
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
            AppBottomNav(activeTab: AppTab.calendar),
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
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
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
    final cells = _viewModel.buildCalendarCells();
    final month = _viewModel.focusedMonth;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lightPurple, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _viewModel.prevMonth,
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
                '${CalendarViewModel.monthNames[month.month]} ${month.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _darkPurple,
                ),
              ),
              GestureDetector(
                onTap: _viewModel.nextMonth,
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
              final isSelected = _viewModel.isSameDay(day, _viewModel.selectedDay);
              final isToday = _viewModel.isToday(day);
              final isCurrentMonth = day.month == month.month;

              return GestureDetector(
                onTap: () => _viewModel.loadDay(day),
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
    final selected = _viewModel.selectedDay;
    final isToday = _viewModel.isSameDay(selected, now);
    final isPast = selected.isBefore(DateTime(now.year, now.month, now.day));
    final dayLabel = isToday
        ? 'Hoje'
        : '${selected.day}/${selected.month}/${selected.year}';

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
        if (_viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: _primaryPurple),
            ),
          )
        else if (_viewModel.dayMedications.isEmpty)
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
          ...(_viewModel.dayMedications
                  .expand((med) => med.schedules.map((s) => (med, s)))
                  .toList()
                ..sort(
                  (a, b) => a.$2.scheduledTime.compareTo(b.$2.scheduledTime),
                ))
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HistoryCard(
                    medication: entry.$1,
                    schedule: entry.$2,
                    isPast: isPast,
                  ),
                ),
              ),
      ],
    );
  }

}
