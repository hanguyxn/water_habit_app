import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_habit_app/core/providers/auth_provider.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_button.dart';
import 'package:water_habit_app/core/widgets/app_text_field.dart';
import 'package:water_habit_app/core/widgets/app_error_widget.dart';
import 'package:water_habit_app/core/widgets/loading_widget.dart';
import 'package:water_habit_app/core/utils/validators.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';
import 'package:water_habit_app/core/localization/localization_providers.dart';
import 'package:water_habit_app/features/profile/providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _goalController;
  String? _selectedAvatarUrl;

  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _goalController = TextEditingController();

    // Prefill data using the current user's profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        final profile = ref.read(profileProvider(currentUser.uid)).value;
        if (profile != null) {
          _nameController.text = profile.displayName ?? '';
          _bioController.text = profile.bio ?? '';
          _goalController.text = profile.dailyGoalMl.toString();
          _selectedAvatarUrl = profile.avatarUrl;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final editor = ref.read(profileEditorProvider.notifier);

    try {
      final goalMl = int.parse(_goalController.text);

      // Save profile updates
      await editor.updateProfile(
        currentUser.uid,
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: _selectedAvatarUrl,
      );

      // Save daily goal updates
      await editor.updateDailyGoal(currentUser.uid, goalMl);

      // Invalidate providers to force refresh
      ref.invalidate(profileProvider(currentUser.uid));
      ref.invalidate(profileStatsProvider(currentUser.uid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('profile.saveSuccess'))),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('profile.saveError')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editorState = ref.watch(profileEditorProvider);
    final isLoading = editorState.isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('${context.tr('profile.editProfile')} 🌿'),
      ),
      body: isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('profile.avatarLabel'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAvatarSelector(),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _nameController,
                      label: context.tr('profile.displayNameLabel'),
                      hint: context.tr('profile.displayNameHint'),
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? context.tr('profile.displayNameRequired')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _bioController,
                      label: context.tr('profile.bioLabel'),
                      hint: 'Chia sẻ ngắn gọn về lối sống lành mạnh của bạn...',
                      prefixIcon: Icons.info_outline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _goalController,
                      label: context.tr('profile.goalLabel'),
                      hint: 'Ví dụ: 2500',
                      prefixIcon: Icons.water_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.tr('profile.goalRequired');
                        final num = int.tryParse(v);
                        if (num == null || num <= 0) return context.tr('profile.goalPositive');
                        if (num < 1000 || num > 5000) {
                          return context.tr('profile.goalRange');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('profile.languageLabel'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language_rounded, color: AppColors.primary500),
                      title: Text(
                        ref.watch(localeProvider).languageCode == 'vi' ? 'Tiếng Việt' : 'English',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Quicksand'),
                      ),
                      trailing: Switch(
                        value: ref.watch(localeProvider).languageCode == 'en',
                        activeColor: AppColors.primary500,
                        onChanged: (val) {
                          ref.read(localeProvider.notifier).toggleLocale();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: context.tr('profile.saveChanges'),
                      onPressed: _saveProfile,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSelector() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _selectedAvatarUrl != null
                ? NetworkImage(_selectedAvatarUrl!)
                : null,
            backgroundColor: AppColors.primary100,
            child: _selectedAvatarUrl == null
                ? const Icon(Icons.person_rounded, size: 50, color: AppColors.primary500)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('profile.presetAvatars'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Quicksand',
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _presetAvatars.length,
              itemBuilder: (context, index) {
                final avatar = _presetAvatars[index];
                final isSelected = _selectedAvatarUrl == avatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarUrl = avatar;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary500 : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(avatar),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
