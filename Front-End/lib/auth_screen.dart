import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/input_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/pill_tab_bar.dart';

/// Tela de autenticação do ServAqui.
///
/// Porta fiel do componente React `AuthScreen.tsx`.
/// Recebe [initialTab] para abrir direto em "Entrar" ou "Criar conta".
///
/// Navegação via Navigator 2.0: em vez de callbacks, usa [Navigator.pushNamed].
/// Rotas esperadas no MaterialApp:
///   '/client-home'        → home do cliente
///   '/entrepreneur-setup' → setup do empreendedor
class AuthScreen extends StatefulWidget {
  /// 0 = Entrar, 1 = Criar conta
  final int initialTab;

  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // ─── estado da aba principal ───────────────────────────────────────────────
  late int _tab; // 0 = login, 1 = register

  // ─── estado do cadastro ────────────────────────────────────────────────────
  int _userType = 0; // 0 = cliente, 1 = empreendedor
  bool _cpfError = false;
  bool _ageError = false;
  bool _acceptTerms = false;
  String _birthDate = '';

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  // ─── lógica ────────────────────────────────────────────────────────────────

  void _checkAge(String dateStr) {
    if (dateStr.isEmpty) return;
    try {
      final birth = DateTime.parse(dateStr);
      final age = DateTime.now().year - birth.year;
      setState(() => _ageError = age < 18);
    } catch (_) {}
  }

  void _handleLogin() {
    Navigator.pushNamed(context, '/client-home');
  }

  void _handleRegister() {
    if (!_acceptTerms) return;
    final route =
    _userType == 1 ? '/entrepreneur-setup' : '/client-home';
    Navigator.pushNamed(context, route);
  }

  // ─── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // ── Tab Entrar / Criar conta ────────────────────────────
                  PillTabBar(
                    labels: const ['Entrar', 'Criar conta'],
                    selectedIndex: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 24),
                  // ── Conteúdo da aba ─────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _tab == 0
                        ? _buildLoginForm()
                        : _buildRegisterForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── header com logo ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone Zap (relâmpago)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'ServAqui',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── formulário de login ────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InputField(
          label: 'E-mail',
          placeholder: 'seu@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const PasswordField(label: 'Senha'),
        const SizedBox(height: 8),

        // Esqueci minha senha
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Esqueci minha senha',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Botão Entrar
        _PrimaryButton(label: 'Entrar', onPressed: _handleLogin),
        const SizedBox(height: 16),

        // Divisor "ou"
        _OrDivider(),
        const SizedBox(height: 16),

        // Botão Google
        _GoogleButton(),
      ],
    );
  }

  // ─── formulário de cadastro ─────────────────────────────────────────────────

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sou Cliente / Sou Empreendedor
        PillTabBar(
          labels: const ['Sou Cliente', 'Sou Empreendedor'],
          selectedIndex: _userType,
          activeColor: AppColors.secondary,
          onChanged: (i) => setState(() => _userType = i),
        ),
        const SizedBox(height: 16),

        const InputField(label: 'Nome completo', placeholder: 'João da Silva'),
        const SizedBox(height: 16),

        // CPF ou CNPJ
        InputField(
          label: _userType == 0 ? 'CPF' : 'CNPJ',
          placeholder:
          _userType == 0 ? '000.000.000-00' : '00.000.000/0001-00',
          keyboardType: TextInputType.number,
          hasError: _cpfError,
          errorText: _cpfError
              ? '${_userType == 0 ? 'CPF' : 'CNPJ'} já cadastrado'
              : null,
          onEditingComplete: () => setState(() => _cpfError = true),
          onTap: () => setState(() => _cpfError = false),
        ),
        const SizedBox(height: 16),

        // Data de nascimento
        _DateField(
          hasError: _ageError,
          errorText:
          _ageError ? 'Você precisa ter pelo menos 18 anos' : null,
          onChanged: (v) {
            _birthDate = v;
            _checkAge(v);
          },
        ),
        const SizedBox(height: 16),

        const InputField(
          label: 'E-mail',
          placeholder: 'seu@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        const PasswordField(label: 'Senha'),
        const SizedBox(height: 16),
        const PasswordField(label: 'Confirmar senha'),
        const SizedBox(height: 16),

        // Aceite dos termos
        _TermsCheckbox(
          accepted: _acceptTerms,
          onChanged: (v) => setState(() => _acceptTerms = v),
        ),
        const SizedBox(height: 16),

        // Botão Criar conta
        _PrimaryButton(
          label: 'Criar conta',
          onPressed: _acceptTerms ? _handleRegister : null,
          enabled: _acceptTerms,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares privados
// ─────────────────────────────────────────────────────────────────────────────

/// Campo de data de nascimento — substitui <input type="date"> do React.
class _DateField extends StatefulWidget {
  final bool hasError;
  final String? errorText;
  final void Function(String) onChanged;

  const _DateField({
    required this.hasError,
    this.errorText,
    required this.onChanged,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  final _controller = TextEditingController();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _controller.text = formatted;
      // Para o checkAge, envia no formato ISO
      widget.onChanged(
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data de nascimento',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: AbsorbPointer(
            child: TextField(
              controller: _controller,
              style:
              const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',
                hintStyle: const TextStyle(
                    color: AppColors.textHint, fontSize: 14),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                suffixIcon: const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.textMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.error
                        : AppColors.border,
                    width: widget.hasError ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.error
                        : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                errorText: widget.errorText,
                errorStyle:
                const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão primário azul do app.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          enabled ? AppColors.primary : AppColors.textHint,
          foregroundColor: Colors.white,
          elevation: enabled ? 4 : 0,
          shadowColor: AppColors.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Divisor "ou" entre login e botão Google.
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

/// Botão "Entrar com Google" (sem lógica OAuth — placeholder visual).
class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        padding:
        const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone Google simplificado com as 4 cores oficiais
          SizedBox(
            width: 18,
            height: 18,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
          const SizedBox(width: 12),
          const Text('Entrar com Google'),
        ],
      ),
    );
  }
}

/// Checkbox de aceite dos termos.
class _TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final void Function(bool) onChanged;

  const _TermsCheckbox(
      {required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!accepted),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: accepted ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color:
                accepted ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: accepted
                ? const Icon(Icons.check,
                size: 13, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4),
              children: [
                TextSpan(text: 'Li e aceito os '),
                TextSpan(
                  text: 'Termos de Uso',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' e a '),
                TextSpan(
                  text: 'Política de Privacidade',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pintor do ícone Google (4 arcos coloridos).
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = size.width / 2;

    void drawArc(Color color, double startAngle, double sweepAngle) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.65),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    const pi = 3.14159265;
    drawArc(const Color(0xFF4285F4), -0.5 * pi, 0.5 * pi);       // azul
    drawArc(const Color(0xFF34A853), 0.0 * pi, 0.5 * pi);        // verde
    drawArc(const Color(0xFFFBBC05), 0.5 * pi, 0.5 * pi);        // amarelo
    drawArc(const Color(0xFFEA4335), 1.0 * pi, 0.5 * pi);        // vermelho
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}