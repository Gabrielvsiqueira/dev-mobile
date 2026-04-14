import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';
import '../routes/app_router.dart';

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
  final _repository = MedicationRepository();

  // Animação do ícone pulsando
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Contador regressivo do "lembrar em 5 min"
  Timer? _snoozeTimer;
  int _snoozeSecondsLeft = 0;
  bool _isSnoozed = false;
  bool _isDone = false;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);

  @override
  void initState() {
    super.initState();

    // Vibração ao abrir a tela (simula o alarme)
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
    _pulseController.dispose();
    _snoozeTimer?.cancel();
    super.dispose();
  }

  // ── Ações ───────────────────────────────────────────────────────────────

  Future<void> _onTaken() async {
    HapticFeedback.mediumImpact();
    setState(() => _isDone = true);
    _pulseController.stop();
    _snoozeTimer?.cancel();

    await _repository.updateStatus(widget.schedule.id, MedicationStatus.taken);

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _onSnooze() {
    if (_isSnoozed) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSnoozed = true;
      _snoozeSecondsLeft = 5 * 60; // 5 minutos em segundos
    });

    _snoozeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _snoozeSecondsLeft--);
      if (_snoozeSecondsLeft <= 0) {
        timer.cancel();
        setState(() => _isSnoozed = false);
        HapticFeedback.heavyImpact();
      }
    });
  }

  String get _snoozeLabel {
    if (!_isSnoozed) return 'Lembrar em 5 minutos';
    final min = _snoozeSecondsLeft ~/ 60;
    final sec = _snoozeSecondsLeft % 60;
    return 'Lembrete em ${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get _recurrenceLabel {
    switch (widget.schedule.recurrenceType) {
      case RecurrenceType.daily:
        return 'Todo dia';
      case RecurrenceType.weekly:
        final days = widget.schedule.weekDays ?? [];
        const map = {
          'mon': 'Seg',
          'tue': 'Ter',
          'wed': 'Qua',
          'thu': 'Qui',
          'fri': 'Sex',
          'sat': 'Sáb',
          'sun': 'Dom',
        };
        return days.map((d) => map[d] ?? d).join(', ');
      case RecurrenceType.interval:
        return 'A cada ${widget.schedule.intervalHours}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bloqueia o botão de voltar do sistema
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _isDone ? const Color(0xFF4CAF50) : _primaryPurple,
        body: SafeArea(child: _isDone ? _buildDoneState() : _buildAlarmState()),
      ),
    );
  }

  // ── Estado: alarme ativo ──────────────────────────────────────────────

  Widget _buildAlarmState() {
    return Column(
      children: [
        // Topo: hora atual
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTimeBadge(), _buildScheduleBadge()],
          ),
        ),

        // Centro: ícone + info do remédio
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPulsingIcon(),
              const SizedBox(height: 32),
              _buildMedInfo(),
              if (widget.medication.notes != null) ...[
                const SizedBox(height: 20),
                _buildNotesCard(),
              ],
              const SizedBox(height: 32),
              _buildAudioBar(),
            ],
          ),
        ),

        // Botões de ação
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
          _recurrenceLabel,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.medication.notes!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
          // Botão play
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
          // Ondas de áudio decorativas
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
                    final heights = [
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
        onPressed: _isSnoozed ? null : _onSnooze,
        icon: Icon(
          _isSnoozed ? Icons.hourglass_top_rounded : Icons.snooze_rounded,
          size: 18,
        ),
        label: Text(_snoozeLabel),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white54,
          side: BorderSide(
            color: _isSnoozed ? Colors.white30 : Colors.white.withOpacity(0.5),
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

  // ── Estado: remédio tomado ───────────────────────────────────────────────

  Widget _buildDoneState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
