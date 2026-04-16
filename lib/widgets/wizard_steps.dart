import 'package:flutter/material.dart';
import '../model/medication.dart';

// ─── Passo 1: Nome e Dosagem ───────────────────────────────────────────────

class WizardStepName extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDosageChanged;

  const WizardStepName({
    super.key,
    required this.nameController,
    required this.dosageController,
    required this.onNameChanged,
    required this.onDosageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardInputField(
            label: 'Nome do medicamento',
            hint: 'Ex: Losartana, Metformina...',
            controller: nameController,
            onChanged: onNameChanged,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          WizardInputField(
            label: 'Dosagem',
            hint: 'Ex: 50mg, 500mg, 1 comprimido...',
            controller: dosageController,
            onChanged: onDosageChanged,
            helperText: 'Quantidade por tomada',
          ),
        ],
      ),
    );
  }
}

// ─── Passo 2: Horários ─────────────────────────────────────────────────────

class WizardStepTime extends StatelessWidget {
  final List<String> selectedTimes;
  final ValueChanged<String> onToggleTime;

  static const _quickTimes = [
    '06:00',
    '08:00',
    '12:00',
    '18:00',
    '20:00',
    '22:00',
  ];
  static const _primaryPurple = Color(0xFF7C5CBF);

  const WizardStepTime({
    super.key,
    required this.selectedTimes,
    required this.onToggleTime,
  });

  Future<void> _pickCustomTime(BuildContext context) async {
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
    onToggleTime(formatted);
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
          if (selectedTimes.isEmpty)
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
              children: selectedTimes
                  .map((t) => TimeChip(
                        time: t,
                        selected: true,
                        onTap: () => onToggleTime(t),
                      ))
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
                .map((t) => TimeChip(
                      time: t,
                      selected: selectedTimes.contains(t),
                      onTap: () => onToggleTime(t),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickCustomTime(context),
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

// ─── Passo 3: Recorrência ──────────────────────────────────────────────────

class WizardStepRecurrence extends StatelessWidget {
  final RecurrenceType recurrenceType;
  final List<String> selectedWeekDays;
  final int intervalHours;
  final ValueChanged<RecurrenceType> onTypeChanged;
  final ValueChanged<String> onDayToggled;
  final ValueChanged<int> onIntervalChanged;

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

  const WizardStepRecurrence({
    super.key,
    required this.recurrenceType,
    required this.selectedWeekDays,
    required this.intervalHours,
    required this.onTypeChanged,
    required this.onDayToggled,
    required this.onIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecurOption(
            label: 'Todo dia',
            subtitle: 'Diariamente no mesmo horário',
            selected: recurrenceType == RecurrenceType.daily,
            onTap: () => onTypeChanged(RecurrenceType.daily),
          ),
          const SizedBox(height: 10),
          RecurOption(
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
                  onTap: () => onDayToggled(e.key),
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
          RecurOption(
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

// ─── Passo 4: Confirmação ──────────────────────────────────────────────────

class WizardStepConfirm extends StatelessWidget {
  final String name;
  final String dosage;
  final List<String> times;
  final String recurrenceLabel;

  const WizardStepConfirm({
    super.key,
    required this.name,
    required this.dosage,
    required this.times,
    required this.recurrenceLabel,
  });

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
          ConfirmRow(
            icon: Icons.medication_rounded,
            label: 'Medicamento',
            value: '$name · $dosage',
          ),
          const SizedBox(height: 10),
          ConfirmRow(
            icon: Icons.access_time_rounded,
            label: 'Horário${times.length > 1 ? 's' : ''}',
            value: times.join('  ·  '),
          ),
          const SizedBox(height: 10),
          ConfirmRow(
            icon: Icons.calendar_month_rounded,
            label: 'Frequência',
            value: recurrenceLabel,
          ),
          const SizedBox(height: 10),
          ConfirmRow(
            icon: Icons.notifications_rounded,
            label: 'Primeiro lembrete',
            value: 'Amanhã, ${times.first}',
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────

class TimeChip extends StatelessWidget {
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const TimeChip({
    super.key,
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

class RecurOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const RecurOption({
    super.key,
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

class ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ConfirmRow({
    super.key,
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

class WizardInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final String? helperText;

  const WizardInputField({
    super.key,
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
