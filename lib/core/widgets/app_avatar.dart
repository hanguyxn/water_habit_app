import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── Friend Status Enum ──────────────────────────────────────────────────────

enum FriendStatusEnum {
  drinking,   // 0 - currently drinking water
  completed,  // 1 - daily goal completed
  inactive,   // 2 - not active today
}

// ─── Avatar Size ─────────────────────────────────────────────────────────────

enum AppAvatarSize {
  small,   // 32
  medium,  // 48
  large,   // 72
  xlarge,  // 96
}

// ─── AppAvatar ───────────────────────────────────────────────────────────────

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.medium,
    this.showStatus = false,
    this.status,
    this.showLevel = false,
    this.level,
    this.heroTag,
    this.onTap,
    this.borderColor,
    this.borderWidth,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final bool showStatus;
  final FriendStatusEnum? status;
  final bool showLevel;
  final int? level;
  final String? heroTag;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double? borderWidth;

  double get _dimension {
    switch (size) {
      case AppAvatarSize.small:
        return 32;
      case AppAvatarSize.medium:
        return 48;
      case AppAvatarSize.large:
        return 72;
      case AppAvatarSize.xlarge:
        return 96;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppAvatarSize.small:
        return 12;
      case AppAvatarSize.medium:
        return 18;
      case AppAvatarSize.large:
        return 26;
      case AppAvatarSize.xlarge:
        return 34;
    }
  }

  double get _statusSize {
    switch (size) {
      case AppAvatarSize.small:
        return 8;
      case AppAvatarSize.medium:
        return 12;
      case AppAvatarSize.large:
        return 16;
      case AppAvatarSize.xlarge:
        return 20;
    }
  }

  double get _levelBadgeSize {
    switch (size) {
      case AppAvatarSize.small:
        return 14;
      case AppAvatarSize.medium:
        return 18;
      case AppAvatarSize.large:
        return 24;
      case AppAvatarSize.xlarge:
        return 30;
    }
  }

  double get _levelFontSize {
    switch (size) {
      case AppAvatarSize.small:
        return 8;
      case AppAvatarSize.medium:
        return 9;
      case AppAvatarSize.large:
        return 11;
      case AppAvatarSize.xlarge:
        return 13;
    }
  }

  Color _statusColor() {
    switch (status) {
      case FriendStatusEnum.drinking:
        return AppColors.statusDrinking;
      case FriendStatusEnum.completed:
        return AppColors.statusCompleted;
      case FriendStatusEnum.inactive:
        return AppColors.statusInactive;
      case null:
        return AppColors.statusInactive;
    }
  }

  String _initials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _initialsBackground() {
    if (name == null || name!.isEmpty) return AppColors.disabled;
    final hash = name.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.accent,
      AppColors.secondary,
      AppColors.secondaryLight,
      const Color(0xFF7CB342),
      const Color(0xFF26A69A),
      const Color(0xFFAB47BC),
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = SizedBox(
      width: _dimension,
      height: _dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildAvatar(),
          if (showStatus && status != null) _buildStatusDot(),
          if (showLevel && level != null) _buildLevelBadge(),
        ],
      ),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildAvatar() {
    final hasBorder = borderColor != null;
    final bw = borderWidth ?? 2.0;

    return Container(
      width: _dimension,
      height: _dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: borderColor!, width: bw) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _hasValidImage
            ? Image.network(
                imageUrl!,
                width: _dimension,
                height: _dimension,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildFallback();
                },
              )
            : _buildFallback(),
      ),
    );
  }

  bool get _hasValidImage =>
      imageUrl != null && imageUrl!.isNotEmpty;

  Widget _buildFallback() {
    return Container(
      width: _dimension,
      height: _dimension,
      decoration: BoxDecoration(
        color: _initialsBackground(),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: TextStyle(
          color: Colors.white,
          fontSize: _fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  Widget _buildStatusDot() {
    final dotSize = _statusSize;
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: _statusColor(),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: dotSize * 0.2),
          boxShadow: [
            BoxShadow(
              color: _statusColor().withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    final badgeSize = _levelBadgeSize;
    final lvl = level ?? 0;
    final levelColor = AppColors.getLevelColor(lvl);

    return Positioned(
      right: -2,
      bottom: -2,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          color: levelColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: levelColor.withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$lvl',
          style: TextStyle(
            color: Colors.white,
            fontSize: _levelFontSize,
            fontWeight: FontWeight.w800,
            fontFamily: 'Nunito',
            height: 1,
          ),
        ),
      ),
    );
  }
}
