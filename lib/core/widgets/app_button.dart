import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── Button Size ─────────────────────────────────────────────────────────────

enum AppButtonSize {
  small,
  medium,
  large,
}

// ─── Button Variant ──────────────────────────────────────────────────────────

enum AppButtonVariant {
  primary,
  secondary,
  text,
  danger,
}

// ─── AppButton ───────────────────────────────────────────────────────────────

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
    this.variant = AppButtonVariant.primary,
  });

  /// Primary button constructor
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.primary;

  /// Secondary (outlined) button constructor
  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.secondary;

  /// Text button constructor
  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.text;

  /// Danger button constructor
  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final AppButtonSize size;
  final AppButtonVariant variant;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget._isDisabled) {
      setState(() => _isPressed = true);
      _animController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget._isDisabled) {
      setState(() => _isPressed = false);
      _animController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget._isDisabled) {
      setState(() => _isPressed = false);
      _animController.reverse();
    }
  }

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 17;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 22;
    }
  }

  double get _spinnerSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 22;
    }
  }

  double get _borderRadius {
    switch (widget.size) {
      case AppButtonSize.small:
        return 10;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget._isDisabled ? null : widget.onPressed,
        child: AnimatedOpacity(
          opacity: widget._isDisabled ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: widget.isFullWidth ? double.infinity : null,
            height: _height,
            child: _buildVariant(),
          ),
        ),
      ),
    );
  }

  Widget _buildVariant() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _buildPrimary();
      case AppButtonVariant.secondary:
        return _buildSecondary();
      case AppButtonVariant.text:
        return _buildText();
      case AppButtonVariant.danger:
        return _buildDanger();
    }
  }

  Widget _buildPrimary() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: _padding,
      decoration: BoxDecoration(
        gradient: widget._isDisabled
            ? const LinearGradient(
                colors: [AppColors.disabled, AppColors.disabled],
              )
            : _isPressed
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF245A42), Color(0xFF47A37A)],
                  )
                : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: widget._isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: _isPressed ? 0.15 : 0.3),
                  blurRadius: _isPressed ? 4 : 12,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
      ),
      child: _buildContent(
        textColor: AppColors.textOnPrimary,
        spinnerColor: AppColors.textOnPrimary,
      ),
    );
  }

  Widget _buildSecondary() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: _padding,
      decoration: BoxDecoration(
        color: _isPressed
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: widget._isDisabled ? AppColors.disabled : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: _buildContent(
        textColor: widget._isDisabled ? AppColors.disabled : AppColors.primary,
        spinnerColor: AppColors.primary,
      ),
    );
  }

  Widget _buildText() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: _padding,
      decoration: BoxDecoration(
        color: _isPressed
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: _buildContent(
        textColor: widget._isDisabled ? AppColors.disabled : AppColors.primary,
        spinnerColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDanger() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: _padding,
      decoration: BoxDecoration(
        gradient: widget._isDisabled
            ? const LinearGradient(
                colors: [AppColors.disabled, AppColors.disabled],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isPressed
                    ? [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]
                    : [AppColors.error, const Color(0xFFEF5350)],
              ),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: widget._isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: _isPressed ? 0.15 : 0.3),
                  blurRadius: _isPressed ? 4 : 12,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
      ),
      child: _buildContent(
        textColor: Colors.white,
        spinnerColor: Colors.white,
      ),
    );
  }

  Widget _buildContent({
    required Color textColor,
    required Color spinnerColor,
  }) {
    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: _iconSize, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w700,
            color: textColor,
            fontFamily: 'Quicksand',
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
