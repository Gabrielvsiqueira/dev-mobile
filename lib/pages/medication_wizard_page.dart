import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';

class MedicationWizardPage extends StatefulWidget {
  final Medication? medication; // null = adicionar, preenchido = editar

  const MedicationWizardPage({super.key, this.medication});

  bool get isEditing => medication != null;

  @override
  State<MedicationWizardPage> createState() => _MedicationWizardPageState();
}

class _MedicationWizardPageState extends State<MedicationWizardPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Dados do formulário
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  RecurrenceType _recurrenceType = RecurrenceType.daily;
  final List<String> _selectedTimes = ['08:00'];
  final List<String> _selectedWeekDays = [];
  int _intervalHours = 8;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  static const _quickTimes = [
    '06:00',
    '08:00',
    '12:00',
    '18:00',
    '20:00',
    '22:00',
  ];
  static const _weekDayLabels = {
    'mon': 'Seg',
    'tue': 'Ter',
    'wed': 'Qua',
    'thu': 'Qui',
    'fri': 'Sex',
    'sat': 'Sáb',
    'sun': 'Dom',
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final med = widget.medication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      if (med.schedules.isNotEmpty) {
        final s = med.schedules.first;
        _recurrenceType = s.recurrenceType;
        _selectedTimes.clear();
        _selectedTimes.addAll(med.schedules.map((s) => s.scheduledTime));
        _selectedWeekDays.addAll(s.weekDays ?? []);
        _intervalHours = s.intervalHours ?? 8;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  bool _canAdvanceStep(int step) {
    switch (step) {
      case 0:
        return _nameController.text.trim().isNotEmpty &&
            _dosageController.text.trim().isNotEmpty;
      case 1:
        return _selectedTimes.isNotEmpty;
      case 2:
        if (_recurrenceType == RecurrenceType.weekly) {
          return _selectedWeekDays.isNotEmpty;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Excluir medicamento?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _darkPurple,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Deseja excluir "${_nameController.text.trim()}"? Essa ação não pode ser desfeita.',
          style: const TextStyle(color: Color(0xFF8A7AAA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final repo = MedicationRepository();
    await repo.removeMedication(widget.medication!.id);
    if (!mounted) return;
    context.pop(true);
  }

  Future<void> _save() async {
    final repo = MedicationRepository();
    final id =
        widget.medication?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final schedules = _selectedTimes.map((time) {
      return MedicationSchedule(
        id: '${id}_$time',
        medicationId: id,
        scheduledTime: time,
        recurrenceType: _recurrenceType,
        weekDays: _recurrenceType == RecurrenceType.weekly
            ? List.from(_selectedWeekDays)
            : null,
        intervalHours: _recurrenceType == RecurrenceType.interval
            ? _intervalHours
            : null,
        status: MedicationStatus.upcoming,
      );
    }).toList();

    final medication = Medication(
      id: id,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      schedules: schedules,
    );

    if (widget.isEditing) {
      await repo.updateMedication(medication); // atualiza no lugar certo
    } else {
      await repo.addMedication(medication);
    }

    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StepName(
                  nameController: _nameController,
                  dosageController: _dosageController,
                  onChanged: () => setState(() {}),
                ),
                _StepTime(
                  selectedTimes: _selectedTimes,
                  onChanged: () => setState(() {}),
                ),
                _StepRecurrence(
                  recurrenceType: _recurrenceType,
                  selectedWeekDays: _selectedWeekDays,
                  intervalHours: _intervalHours,
                  onTypeChanged: (t) => setState(() => _recurrenceType = t),
                  onDaysChanged: () => setState(() {}),
                  onIntervalChanged: (h) => setState(() => _intervalHours = h),
                ),
                _StepConfirm(
                  name: _nameController.text.trim(),
                  dosage: _dosageController.text.trim(),
                  times: _selectedTimes,
                  recurrenceType: _recurrenceType,
                  weekDays: _selectedWeekDays,
                  intervalHours: _intervalHours,
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Qual o nome\ndo remédio?',
      'Que horas\ntoma esse remédio?',
      'Com que\nfrequência?',
      'Tudo certo?\nConfirme aqui!',
    ];

    return Stack(
      children: [
        Container(
          color: _primaryPurple,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _currentStep > 0
                    ? _goToStep(_currentStep - 1)
                    : context.pop(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFFD4C5F5),
                      size: 20,
                    ),
                    Text(
                      _currentStep == 0 ? 'Cancelar' : 'Voltar',
                      style: const TextStyle(
                        color: Color(0xFFD4C5F5),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  _totalSteps,
                  (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: i < _totalSteps - 1 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                titles[_currentStep],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Passo ${_currentStep + 1} de $_totalSteps',
                style: const TextStyle(
                  color: Color(0xFFD4C5F5),
                  fontSize: 12,
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

  Widget _buildBottomBar() {
    final isLast = _currentStep == _totalSteps - 1;
    final canAdvance = _canAdvanceStep(_currentStep);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAE4F7), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canAdvance
                  ? () => isLast ? _save() : _goToStep(_currentStep + 1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFBFA8EE),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(isLast ? 'Salvar remédio' : 'Próximo'),
            ),
          ),
          if (isLast) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _goToStep(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkPurple,
                  side: const BorderSide(color: Color(0xFFEAE4F7), width: 1.5),
                  backgroundColor: _lightPurple,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Corrigir algo'),
              ),
            ),
          ],
          if (widget.isEditing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Excluir medicamento'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Passo 1: Nome e Dosagem ───────────────────────────────────────────────

class _StepName extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final VoidCallback onChanged;

  const _StepName({
    required this.nameController,
    required this.dosageController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WizardInputField(
            label: 'Nome do medicamento',
            hint: 'Ex: Losartana, Metformina...',
            controller: nameController,
            onChanged: (_) => onChanged(),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          _WizardInputField(
            label: 'Dosagem',
            hint: 'Ex: 50mg, 500mg, 1 comprimido...',
            controller: dosageController,
            onChanged: (_) => onChanged(),
            helperText: 'Quantidade por tomada',
          ),
        ],
      ),
    );
  }
}

// ─── Passo 2: Horários ─────────────────────────────────────────────────────

class _StepTime extends StatefulWidget {
  final List<String> selectedTimes;
  final VoidCallback onChanged;

  const _StepTime({required this.selectedTimes, required this.onChanged});

  @override
  State<_StepTime> createState() => _StepTimeState();
}

class _StepTimeState extends State<_StepTime> {
  static const _quickTimes = [
    '06:00',
    '08:00',
    '12:00',
    '18:00',
    '20:00',
    '22:00',
  ];
  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);

  void _toggleTime(String time) {
    setState(() {
      if (widget.selectedTimes.contains(time)) {
        if (widget.selectedTimes.length > 1) widget.selectedTimes.remove(time);
      } else {
        widget.selectedTimes.add(time);
        widget.selectedTimes.sort();
      }
    });
    widget.onChanged();
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primaryPurple),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    _toggleTime(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HORÁRIOS SELECIONADOS',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.selectedTimes.isEmpty)
            const Text(
              'Nenhum horário selecionado ainda',
              style: TextStyle(
                color: Color(0xFF9B8EC4),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedTimes
                  .map(
                    (t) => _TimeChip(
                      time: t,
                      selected: true,
                      onTap: () => _toggleTime(t),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          const Text(
            'ATALHOS RÁPIDOS',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTimes
                .map(
                  (t) => _TimeChip(
                    time: t,
                    selected: widget.selectedTimes.contains(t),
                    onTap: () => _toggleTime(t),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickCustomTime,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Outro horário...'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryPurple,
                side: const BorderSide(color: Color(0xFFEAE4F7), width: 1.5),
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5CBF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF7C5CBF) : const Color(0xFFEAE4F7),
            width: 1.5,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : const Color(0xFF4A2E8C),
          ),
        ),
      ),
    );
  }
}

// ─── Passo 3: Recorrência ──────────────────────────────────────────────────

class _StepRecurrence extends StatelessWidget {
  final RecurrenceType recurrenceType;
  final List<String> selectedWeekDays;
  final int intervalHours;
  final ValueChanged<RecurrenceType> onTypeChanged;
  final VoidCallback onDaysChanged;
  final ValueChanged<int> onIntervalChanged;

  const _StepRecurrence({
    required this.recurrenceType,
    required this.selectedWeekDays,
    required this.intervalHours,
    required this.onTypeChanged,
    required this.onDaysChanged,
    required this.onIntervalChanged,
  });

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _weekDays = {
    'mon': 'Seg',
    'tue': 'Ter',
    'wed': 'Qua',
    'thu': 'Qui',
    'fri': 'Sex',
    'sat': 'Sáb',
    'sun': 'Dom',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecurOption(
            label: 'Todo dia',
            subtitle: 'Diariamente no mesmo horário',
            selected: recurrenceType == RecurrenceType.daily,
            onTap: () => onTypeChanged(RecurrenceType.daily),
          ),
          const SizedBox(height: 10),
          _RecurOption(
            label: 'Dias da semana',
            subtitle: 'Escolha os dias específicos',
            selected: recurrenceType == RecurrenceType.weekly,
            onTap: () => onTypeChanged(RecurrenceType.weekly),
          ),
          if (recurrenceType == RecurrenceType.weekly) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekDays.entries.map((e) {
                final isSelected = selectedWeekDays.contains(e.key);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      selectedWeekDays.remove(e.key);
                    } else {
                      selectedWeekDays.add(e.key);
                    }
                    onDaysChanged();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryPurple : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _primaryPurple
                            : const Color(0xFFEAE4F7),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A2E8C),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          _RecurOption(
            label: 'A cada X horas',
            subtitle: 'Intervalo fixo entre doses',
            selected: recurrenceType == RecurrenceType.interval,
            onTap: () => onTypeChanged(RecurrenceType.interval),
          ),
          if (recurrenceType == RecurrenceType.interval) ...[
            const SizedBox(height: 12),
            const Text(
              'INTERVALO EM HORAS',
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [4, 6, 8, 12, 24].map((h) {
                final isSelected = intervalHours == h;
                return GestureDetector(
                  onTap: () => onIntervalChanged(h),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryPurple : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _primaryPurple
                            : const Color(0xFFEAE4F7),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'a cada ${h}h',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A2E8C),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecurOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RecurOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3F0FA) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF7C5CBF) : const Color(0xFFEAE4F7),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF7C5CBF) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF7C5CBF)
                      : const Color(0xFFBFA8EE),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1B5E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9B8EC4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Passo 4: Confirmação ──────────────────────────────────────────────────

class _StepConfirm extends StatelessWidget {
  final String name;
  final String dosage;
  final List<String> times;
  final RecurrenceType recurrenceType;
  final List<String> weekDays;
  final int intervalHours;

  const _StepConfirm({
    required this.name,
    required this.dosage,
    required this.times,
    required this.recurrenceType,
    required this.weekDays,
    required this.intervalHours,
  });

  static const _weekDayLabels = {
    'mon': 'Seg',
    'tue': 'Ter',
    'wed': 'Qua',
    'thu': 'Qui',
    'fri': 'Sex',
    'sat': 'Sáb',
    'sun': 'Dom',
  };

  String get _recurrenceLabel {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'Todo dia';
      case RecurrenceType.weekly:
        if (weekDays.isEmpty) return 'Dias da semana (nenhum selecionado)';
        return weekDays.map((d) => _weekDayLabels[d] ?? d).join(', ');
      case RecurrenceType.interval:
        return 'A cada ${intervalHours}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMO DO REMÉDIO',
            style: TextStyle(
              color: Color(0xFF7C5CBF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _ConfirmRow(
            icon: Icons.medication_rounded,
            label: 'Medicamento',
            value: '$name · $dosage',
          ),
          const SizedBox(height: 10),
          _ConfirmRow(
            icon: Icons.access_time_rounded,
            label: 'Horário${times.length > 1 ? 's' : ''}',
            value: times.join('  ·  '),
          ),
          const SizedBox(height: 10),
          _ConfirmRow(
            icon: Icons.calendar_month_rounded,
            label: 'Frequência',
            value: _recurrenceLabel,
          ),
          const SizedBox(height: 10),
          _ConfirmRow(
            icon: Icons.notifications_rounded,
            label: 'Primeiro lembrete',
            value: 'Amanhã, ${times.first}',
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE4F7), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAE4F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF7C5CBF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B8EC4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D1B5E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Campo de input reutilizável ───────────────────────────────────────────

class _WizardInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final String? helperText;

  const _WizardInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.autofocus = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF7C5CBF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          autofocus: autofocus,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D1B5E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC0B0E0),
            ),
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9B8EC4),
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEAE4F7),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEAE4F7),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF7C5CBF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
