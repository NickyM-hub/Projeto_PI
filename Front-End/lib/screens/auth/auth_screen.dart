import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/input_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/pill_tab_bar.dart';

class AuthScreen extends StatelessWidget {

  final int initialTab;

  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

  class _AuthScreenState extends State<AuthScreen> {

    late int _tab;

    int _userType = 0;
    bool _cpfError = false;
    bool _ageError = false;
    bool _acceptTerms = false;
    String _birthDate = '';

    @override
    void initState() {
      super.initState();
      _tab = widget.initialTab;
    }

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

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor:  AppColors.background,
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

                      PillTabBar(
                          labels: const ['Entrar', 'Criar conta'],
                          selectedIndex: _tab, 
                          onChanged: (i) => setState(() => _tab = i),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: _tab == 0
                              ? = _buildLoginForm()
                              : = _buildRegisterForm (),
                      )
                    ],
                  ),
                )
            )
          ],
        ),
      )
    }
}