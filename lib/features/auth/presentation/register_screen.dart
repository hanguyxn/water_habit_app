import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_button.dart';
import 'package:water_habit_app/core/widgets/app_text_field.dart';
import 'package:water_habit_app/core/utils/validators.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('auth.agreeTermsRequired'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = Validators.passwordStrength(_passwordController.text);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary700, AppColors.backgroundLight],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                  ],
                ),
                const Icon(Icons.eco_rounded, size: 56, color: Colors.white)
                    .animate()
                    .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(
                  context.tr('auth.registerTitle'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  context.tr('auth.registerSubtitle'),
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _usernameController,
                          label: context.tr('auth.usernameLabel'),
                          hint: '@username',
                          prefixIcon: Icons.alternate_email,
                          validator: Validators.username,
                        ),
                        const SizedBox(height: 16),
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
                          onChanged: (_) => setState(() {}),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.primary500),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 8),
                        // Password strength indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: passwordStrength,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              passwordStrength < 0.5
                                  ? Colors.red
                                  : passwordStrength < 0.75
                                      ? Colors.orange
                                      : AppColors.primary500,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: context.tr('auth.confirmPasswordLabel'),
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.primary500),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeTerms,
                              onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                              activeColor: AppColors.primary500,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                                child: Text(
                                  context.tr('auth.agreeTerms'),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: context.tr('auth.registerButton'),
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0, delay: 400.ms),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        context.tr('auth.alreadyHaveAccount'),
                        style: const TextStyle(color: AppColors.primary500, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
