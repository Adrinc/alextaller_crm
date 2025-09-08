import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/services/api_error_handler.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  bool passwordVisibility = false;
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    Future<void> login() async {
      setState(() => _isLoading = true);
      _buttonController.forward().then((_) => _buttonController.reverse());

      //Login
      try {
        // Check if user exists
        final userId =
            await userState.getUserId(userState.emailController.text);

        if (userId == null) {
          await ApiErrorHandler.callToast('Este Correo no está registrado');
          setState(() => _isLoading = false);
          return;
        }

        await supabase.auth.signInWithPassword(
          email: userState.emailController.text,
          password: userState.passwordController.text,
        );

        if (userState.recuerdame == true) {
          await userState.setEmail();
          await userState.setPassword();
        } else {
          userState.emailController.text = '';
          userState.passwordController.text = '';
          await prefs.remove('email');
          await prefs.remove('password');
        }

        if (supabase.auth.currentUser == null) {
          await ApiErrorHandler.callToast();
          setState(() => _isLoading = false);
          return;
        }

        currentUser = await SupabaseQueries.getCurrentUserData();

        if (currentUser == null) {
          await ApiErrorHandler.callToast('Error al obtener datos del usuario');
          setState(() => _isLoading = false);
          return;
        }

        // Recargar el tema del usuario después de la autenticación
        log('Usuario autenticado exitosamente: ${currentUser!.id}');
        print('🚀 [LoginForm] Usuario autenticado: ${currentUser!.id}');

        // Usar el provider para recargar el tema del usuario
        if (mounted) {
          print('🚀 [LoginForm] Iniciando recarga de tema...');
          final themeProvider =
              Provider.of<ThemeConfigProvider>(context, listen: false);
          await themeProvider.reloadUserTheme();
          print('🚀 [LoginForm] Recarga de tema completada');
        }

        /* 
        13: limitado
        14: ilimitado
         */

        /* ILIMITADO */
        print('User Role ID: ${currentUser!.role.roleId}');
        /*    if (currentUser!.role.roleId == 14 || currentUser!.role.roleId == 13) {
          context.pushReplacement('/book_page_main');
          return;
        } */
        /* LIMITADO */

        if (!mounted) return;

        context.pushReplacement('/');
      } catch (e) {
        if (e is sf.AuthException) {
          await userState.incrementLoginAttempts(
            userState.emailController.text,
          );
          await ApiErrorHandler.callToast('Credenciales Invalidas');
          setState(() => _isLoading = false);
          return;
        }
        log('Error al iniciar sesion - $e');
        setState(() => _isLoading = false);
      }
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo NetHive para formulario (solo en desktop)
            MediaQuery.of(context).size.width >= 768
                ? Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 237, 59, 246),
                                    Color.fromARGB(255, 137, 16, 185)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/images/favicon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenido a NetHive',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Plataforma de Gestión de Infraestructura',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 185, 16, 162),
                                Color.fromARGB(255, 199, 59, 246)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),

            // Título
            Text(
              'CORREO ELECTRÓNICO',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Campo de email con efectos mejorados
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextFormField(
                controller: userState.emailController,
                onFieldSubmitted: (value) async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  await login();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es requerido';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Favor de ingresar un correo valido';
                  }
                  return null;
                },
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'admin@talleralex.com',
                  hintStyle: GoogleFonts.inter(
                    color: isMobile
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.4),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: isMobile
                      ? Colors.white.withOpacity(0.15) // Más opaco en móvil
                      : Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 185, 16, 171),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.email_outlined,
                      color: isMobile
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white60,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Título contraseña
            Text(
              'CONTRASEÑA',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Campo de contraseña con efectos mejorados
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextFormField(
                controller: userState.passwordController,
                obscureText: !passwordVisibility,
                onFieldSubmitted: (value) async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  await login();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  return null;
                },
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: GoogleFonts.inter(
                    color: isMobile
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.4),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: isMobile
                      ? Colors.white.withOpacity(0.15) // Más opaco en móvil
                      : Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: const Color.fromARGB(255, 182, 16, 185),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.lock_outline,
                      color: isMobile
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white60,
                      size: 20,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisibility
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isMobile
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white60,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => passwordVisibility = !passwordVisibility,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de iniciar sesión mejorado
            ScaleTransition(
              scale: _buttonScale,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isMobile
                          ? const Color.fromARGB(255, 132, 3, 161)
                              .withOpacity(0.6) // Azul en móvil
                          : const Color.fromARGB(255, 182, 16, 185)
                              .withOpacity(0.4), // Verde en desktop
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          await login();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMobile
                        ? const Color.fromARGB(
                            255, 127, 3, 161) // Azul más contrastante en móvil
                        : const Color.fromARGB(
                            255, 185, 16, 176), // Verde en desktop
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'INICIAR SESIÓN',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Enlace "Conexión segura" mejorado
            Center(
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: const Color.fromARGB(255, 182, 16, 185),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Conexión segura',
                      style: GoogleFonts.inter(
                        color: const Color.fromARGB(255, 182, 16, 185),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Características principales con diseño mejorado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: const Color.fromARGB(255, 182, 16, 185),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CARACTERÍSTICAS PRINCIPALES',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('Gestión completa de infraestructura',
                          Icons.dashboard_outlined),
                      _buildFeatureItem(
                          'Monitoreo en tiempo real', Icons.analytics_outlined),
                      _buildFeatureItem(
                          'Reportes avanzados', Icons.assessment_outlined),
                      _buildFeatureItem(
                          'Dashboard intuitivo', Icons.widgets_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 182, 16, 185).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 182, 16, 185),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
