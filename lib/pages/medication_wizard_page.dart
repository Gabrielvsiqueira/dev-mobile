import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../repository/medication_repository.dart';
import '../viewmodels/wizard_view_model.dart';
import '../widgets/wizard_steps.dart';

class MedicationWizardPage extends StatefulWidget {
  final Medication? medication;

  const MedicationWizardPage({super.key, this.medication});

  bool get isEditing => medication != null;

  @override
  State<MedicationWizardPage> createState() => _MedicationWizardPageState();
}

class _MedicationWizardPageState extends State<MedicationWizardPage> {
  late WizardViewModel _viewModel;
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  @override
  void initState() {
    super.initState();
    _viewModel = WizardViewModel(
      MedicationRepository(),
      initialMedication: widget.medication,
    );
    _nameController.text = _viewModel.name;
    _dosageController.text = _viewModel.dosage;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _navigateToStep(int step) {
    if (step < 0 || step >= WizardViewModel.totalSteps) return;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _viewModel.goToStep(step);
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
          'Deseja excluir "${_viewModel.name.trim()}"? Essa ação não pode ser desfeita.',
          style: const TextStyle(color: Color(0xFF8A7AAA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _viewModel.delete();
    if (!mounted) return;
    context.pop(true);
  }

  Future<void> _save() async {
    await _viewModel.save();
    if (!mounted) return;
    context.pop(true);
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
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WizardStepName(
                    nameController: _nameController,
                    dosageController: _dosageController,
                    onNameChanged: _viewModel.updateName,
                    onDosageChanged: _viewModel.updateDosage,
                  ),
                  WizardStepTime(
                    selectedTimes: _viewModel.selectedTimes,
                    onToggleTime: _viewModel.toggleTime,
                  ),
                  WizardStepRecurrence(
                    recurrenceType: _viewModel.recurrenceType,
                    selectedWeekDays: _viewModel.selectedWeekDays,
                    intervalHours: _viewModel.intervalHours,
                    onTypeChanged: _viewModel.setRecurrenceType,
                    onDayToggled: _viewModel.toggleWeekDay,
                    onIntervalChanged: _viewModel.setIntervalHours,
                  ),
                  WizardStepConfirm(
                    name: _viewModel.name,
                    dosage: _viewModel.dosage,
                    times: _viewModel.selectedTimes,
                    recurrenceLabel: _viewModel.recurrenceLabel,
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
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
    final step = _viewModel.currentStep;
    final total = WizardViewModel.totalSteps;

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
                onTap: () => step > 0 ? _navigateToStep(step - 1) : context.pop(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFFD4C5F5),
                      size: 20,
                    ),
                    Text(
                      step == 0 ? 'Cancelar' : 'Voltar',
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
                  total,
                  (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i <= step
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
                titles[step],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Passo ${step + 1} de $total',
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
    final step = _viewModel.currentStep;
    final isLast = step == WizardViewModel.totalSteps - 1;
    final canAdvance = _viewModel.canAdvance(step);

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
                  ? () => isLast ? _save() : _navigateToStep(step + 1)
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
                onPressed: () => _navigateToStep(step - 1),
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
          if (_viewModel.isEditing) ...[
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

