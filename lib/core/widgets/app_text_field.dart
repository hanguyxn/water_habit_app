import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── AppTextField ────────────────────────────────────────────────────────────

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusAnimController;
  late final Animation<double> _borderAnimation;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _focusAnimController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, _) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText && !_obscureVisible,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          cursorColor: AppColors.primary,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
            color: widget.enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Quicksand',
              color: _isFocused ? AppColors.primary : AppColors.textTertiary,
            ),
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Quicksand',
              color: AppColors.textHint,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: widget.fillColor ??
                (widget.enabled
                    ? (_isFocused
                        ? AppColors.primarySurface.withValues(alpha: 0.3)
                        : AppColors.backgroundLightSecondary.withValues(alpha: 0.5))
                    : AppColors.disabledBackground),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: _isFocused ? AppColors.primary : AppColors.textTertiary,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            suffix: widget.suffix,

            // ─── Border Styling ──────────────────────────────────
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Color.lerp(
                  AppColors.border,
                  AppColors.primary,
                  _borderAnimation.value,
                )!,
                width: 1.5 + (_borderAnimation.value * 0.5),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.disabledBackground,
                width: 1,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Quicksand',
              color: AppColors.error,
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return GestureDetector(
        onTap: () => setState(() => _obscureVisible = !_obscureVisible),
        child: Icon(
          _obscureVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 20,
          color: _isFocused ? AppColors.primary : AppColors.textTertiary,
        ),
      );
    }
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        size: 20,
        color: _isFocused ? AppColors.primary : AppColors.textTertiary,
      );
    }
    return null;
  }
}
