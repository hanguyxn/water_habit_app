import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_button.dart';
import 'package:water_habit_app/core/widgets/app_text_field.dart';
import 'package:water_habit_app/core/utils/validators.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';
import 'package:water_habit_app/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:water_habit_app/routing/route_names.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Implement with auth repository when Firebase is configured
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary700, AppColors.backgroundLight],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 52,
                    color: AppColors.primary500,
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                Text(
                  context.tr('auth.loginTitle'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  context.tr('auth.loginSubtitle'),
                  style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85)),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),
                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _emailController,
                          label: context.tr('auth.emailLabel'),
                          hint: 'example@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: context.tr('auth.passwordLabel'),
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.primary500,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => v == null || v.isEmpty ? context.tr('auth.passwordHint') : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                            context.tr('auth.forgotPassword'),
                            style: const TextStyle(color: AppColors.primary500),
                          ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: context.tr('auth.loginButton'),
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                context.tr('auth.or'),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const SocialLoginButtons(),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0, delay: 500.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        context.tr('auth.dontHaveAccount'),
                        style: const TextStyle(color: AppColors.primary500, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
