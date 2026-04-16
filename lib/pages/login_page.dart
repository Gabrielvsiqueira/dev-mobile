import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart' show AppRoutes, AppSession;
import '../viewmodels/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginViewModel _viewModel;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _darkPurple = Color(0xFF2D1B5E);
  static const _softBg = Color(0xFFF7F4F0);

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
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

  Future<void> _onEnter() async {
    final name = _nameController.text.trim();
    if (!_viewModel.validate(name)) {
      _nameFocus.requestFocus();
      return;
    }

    AppSession.userName = name;
    AppSession.userPhone = _phoneController.text.trim();
    await _viewModel.login();

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: _softBg,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(children: [_buildHero(), _buildBody()]),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        Container(
          color: _primaryPurple,
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 32,
            bottom: 48,
          ),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF5A3E9E),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFA8EE), width: 2),
                ),
                child: const Icon(
                  Icons.elderly_woman_rounded,
                  color: Color(0xFFBFA8EE),
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Alô, Nenê!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu lembrete de remédios\ncom muito carinho 💜',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD4C5F5),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
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
            height: 28,
            decoration: const BoxDecoration(
              color: _softBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMO TE CHAMAMOS?',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Seu nome',
            hint: 'Ex: Dona Nenê, Maria...',
            controller: _nameController,
            focusNode: _nameFocus,
            icon: Icons.person_rounded,
            nextFocus: _phoneFocus,
            inputType: TextInputType.name,
            hasError: _viewModel.nameError,
            errorText: 'Por favor, informe seu nome para continuar',
            onChanged: (_) => _viewModel.clearNameError(),
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: 'Seu telefone',
            hint: '(44) 99999-9999',
            controller: _phoneController,
            focusNode: _phoneFocus,
            icon: Icons.phone_rounded,
            inputType: TextInputType.phone,
            helperText: 'Usado apenas para lembretes de emergência',
            onSubmitted: (_) => _onEnter(),
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneInputFormatter(),
            ],
          ),
          const SizedBox(height: 40),
          _buildEnterButton(),
          const SizedBox(height: 23),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    FocusNode? nextFocus,
    TextInputType inputType = TextInputType.text,
    String? helperText,
    String? errorText,
    bool hasError = false,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: hasError ? const Color(0xFFC62828) : const Color(0xFF4A2E8C),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, child) {
            final isFocused = focusNode.hasFocus;
            return Container(
              height: 56,
              decoration: BoxDecoration(
                color: hasError ? const Color(0xFFFFF5F5) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFC62828)
                      : isFocused
                      ? _primaryPurple
                      : const Color(0xFFEAE4F7),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    icon,
                    size: 20,
                    color: isFocused ? _primaryPurple : const Color(0xFF9B8EC4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: inputType,
                      inputFormatters: formatters,
                      textInputAction: nextFocus != null
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onChanged: onChanged,
                      onSubmitted: (v) {
                        if (nextFocus != null) {
                          nextFocus.requestFocus();
                        } else {
                          onSubmitted?.call(v);
                        }
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _darkPurple,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(
                          color: Color(0xFFC0B0E0),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            );
          },
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 5),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFC62828),
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 5),
          Text(
            helperText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9B8EC4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _viewModel.isLoading ? null : _onEnter,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFBFA8EE),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _viewModel.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text('Entrar no app'),
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
