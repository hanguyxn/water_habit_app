import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';
import 'package:water_habit_app/features/profile/domain/profile_model.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.stats,
    this.isOwnProfile = false,
    this.onEditPressed,
    this.onAddFriendPressed,
    this.onSendSupportPressed,
  });

  final UserModel user;
  final ProfileStats stats;
  final bool isOwnProfile;
  final VoidCallback? onEditPressed;
  final VoidCallback? onAddFriendPressed;
  final VoidCallback? onSendSupportPressed;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with TickerProviderStateMixin {
  late final AnimationController _avatarController;
  late final AnimationController _streakController;
  late final Animation<double> _avatarScale;
  late final Animation<double> _streakBounce;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _streakBounce = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _streakController, curve: Curves.elasticOut),
    );

    _avatarController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _streakController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _streakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0D1F0D),
                  const Color(0xFF1A2E1A),
                  const Color(0xFF1B4332),
                ]
              : [
                  const Color(0xFF1B4332),
                  const Color(0xFF2D6A4F),
                  const Color(0xFF40916C),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 16),
              _buildNameSection(),
              if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildBio(),
              ],
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 20),
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final levelColor = AppColors.getLevelColor(widget.stats.level);
    final xpProgress = widget.stats.xpForNextLevel > 0
        ? widget.stats.xp / widget.stats.xpForNextLevel
        : 0.0;

    return ScaleTransition(
      scale: _avatarScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // XP Progress Ring
          SizedBox(
            width: 120,
            height: 120,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: xpProgress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                );
              },
            ),
          ),
          // Prestige frame
          if (widget.stats.prestigeStars > 0)
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.user.avatarUrl != null
                  ? Image.network(
                      widget.user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          // Level badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    levelColor,
                    levelColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: levelColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                'Lv.${widget.stats.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
          // Streak badge
          if (widget.stats.currentStreak > 0)
            Positioned(
              top: 0,
              right: 0,
              child: ScaleTransition(
                scale: _streakBounce,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.fireGradient,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.stats.currentStreak}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Prestige stars
          if (widget.stats.prestigeStars > 0)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.stats.prestigeStars.clamp(0, 5),
                    (_) => const Text('⭐', style: TextStyle(fontSize: 8)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final name = widget.user.displayName ?? widget.user.username;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildNameSection() {
    return Column(
      children: [
        Text(
          widget.user.displayName ?? widget.user.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Nunito',
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${widget.user.username}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Text(
      widget.user.bio!,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.85),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Quicksand',
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    if (widget.isOwnProfile) {
      return _buildNatureButton(
        icon: Icons.edit_rounded,
        label: 'Chỉnh sửa hồ sơ',
        onTap: widget.onEditPressed,
        isPrimary: false,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildNatureButton(
            icon: Icons.person_add_rounded,
            label: 'Kết bạn',
            onTap: widget.onAddFriendPressed,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNatureButton(
            icon: Icons.water_drop_rounded,
            label: 'Cổ vũ',
            onTap: widget.onSendSupportPressed,
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildNatureButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickStat(
            '${widget.stats.totalWaterLiters.toStringAsFixed(1)}L',
            'Tổng nước',
          ),
          _buildQuickStatDivider(),
          _buildQuickStat(
            '${widget.stats.currentStreak}',
            'Chuỗi ngày',
          ),
          _buildQuickStatDivider(),
          _buildQuickStat(
            '${widget.stats.friendCount}',
            'Bạn bè',
          ),
          _buildQuickStatDivider(),
          _buildQuickStat(
            '${widget.stats.achievementCount}',
            'Huy hiệu',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
