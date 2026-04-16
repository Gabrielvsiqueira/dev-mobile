import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';
import '../routes/app_router.dart';
import '../viewmodels/alarm_view_model.dart';

class AlarmPage extends StatefulWidget {
  final Medication medication;
  final MedicationSchedule schedule;

  const AlarmPage({
    super.key,
    required this.medication,
    required this.schedule,
  });

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage>
    with SingleTickerProviderStateMixin {
  late AlarmViewModel _viewModel;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _primaryPurple = Color(0xFF7C5CBF);

  @override
  void initState() {
    super.initState();
    _viewModel = AlarmViewModel(
      MedicationRepository(),
      medication: widget.medication,
      schedule: widget.schedule,
    );

    HapticFeedback.heavyImpact();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onTaken() async {
    HapticFeedback.mediumImpact();
    _pulseController.stop();
    await _viewModel.takeMedication();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _onSnooze() {
    HapticFeedback.selectionClick();
    _viewModel.snooze();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: _viewModel.isDone
              ? const Color(0xFF4CAF50)
              : _primaryPurple,
          body: SafeArea(
            child: _viewModel.isDone ? _buildDoneState() : _buildAlarmState(),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTimeBadge(), _buildScheduleBadge()],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPulsingIcon(),
              const SizedBox(height: 32),
              _buildMedInfo(),
              const SizedBox(height: 32),
              _buildAudioBar(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              _buildTakenButton(),
              const SizedBox(height: 12),
              _buildSnoozeButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBadge() {
    final now = TimeOfDay.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$h:$m',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildScheduleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            widget.schedule.scheduledTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: _primaryPurple,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedInfo() {
    return Column(
      children: [
        const Text(
          'Hora do remédio!',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.medication.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.medication.dosage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _viewModel.recurrenceLabel,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: _primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mensagem da família',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(20, (i) {
                    const heights = [
                      6.0,
                      10.0,
                      14.0,
                      8.0,
                      16.0,
                      10.0,
                      6.0,
                      12.0,
                      18.0,
                      10.0,
                      8.0,
                      14.0,
                      6.0,
                      10.0,
                      16.0,
                      8.0,
                      12.0,
                      6.0,
                      10.0,
                      8.0,
                    ];
                    return Container(
                      width: 3,
                      height: heights[i],
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '0:08',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakenButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onTaken,
        icon: const Icon(Icons.check_circle_rounded, size: 22),
        label: const Text('Tomei o remédio'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _primaryPurple,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSnoozeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _viewModel.isSnoozed ? null : _onSnooze,
        icon: Icon(
          _viewModel.isSnoozed
              ? Icons.hourglass_top_rounded
              : Icons.snooze_rounded,
          size: 18,
        ),
        label: Text(_viewModel.snoozeLabel),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white54,
          side: BorderSide(
            color: _viewModel.isSnoozed
                ? Colors.white30
                : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF4CAF50),
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Muito bem!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remédio registrado ✓',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Voltando para a tela principal...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        ],
      ),
    );
  }
}
