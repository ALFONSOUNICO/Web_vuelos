import 'package:flutter/material.dart';

import '../services/sap_service.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text;

    try {
      final sapService = SapService();

      // Validamos las credenciales realizando una consulta real
      // al servicio Dashboard de SAP.
      await sapService.getDashboard(usuario: usuario, password: password);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppShell(usuario: usuario, password: password),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;

        if (e.toString().contains('Usuario o contraseña')) {
          _error = 'Usuario o contraseña incorrectos.';
        } else if (e.toString().contains('autorizaciones')) {
          _error = 'El usuario no tiene autorización para consultar SAP.';
        } else {
          _error =
              'No fue posible conectarse con SAP.\n'
              'Verifique la conexión e inténtelo nuevamente.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Center(
                      child: Text(
                        'SAP Flight Analytics',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'Acceso al centro de análisis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Usuario SAP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _usuarioController,
                      enabled: !_loading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Ingrese su usuario',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese su usuario.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !_loading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: 'Ingrese su contraseña',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: _loading
                              ? null
                              : () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese su contraseña.';
                        }

                        return null;
                      },
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.primaryRed.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _login,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(
                          _loading ? 'Validando acceso...' : 'Ingresar',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Las credenciales se utilizan únicamente '
                        'durante la sesión actual.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
