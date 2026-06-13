import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── Nav Item Data ───────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.emoji,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String emoji;
}

// ─── AppBottomNav ────────────────────────────────────────────────────────────

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.water_drop_outlined,
      activeIcon: Icons.water_drop_rounded,
      label: 'Home',
      emoji: '💧',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Friends',
      emoji: '🌿',
    ),
    _NavItem(
      icon: Icons.dynamic_feed_outlined,
      activeIcon: Icons.dynamic_feed_rounded,
      label: 'Feed',
      emoji: '🌊',
    ),
    _NavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Ranks',
      emoji: '🏆',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      emoji: '🌱',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              return _NavItemWidget(
                item: _items[index],
                isActive: currentIndex == index,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item Widget ─────────────────────────────────────────────────────────

class _NavItemWidget extends StatefulWidget {
  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _activeController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _activeAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _activeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.isActive ? 1.0 : 0.0,
    );
    _activeAnim = CurvedAnimation(
      parent: _activeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_NavItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _activeController.forward();
        // Bounce effect
        _scaleController.forward().then((_) => _scaleController.reverse());
      } else {
        _activeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _activeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnim, _activeAnim]),
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active indicator pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: widget.isActive ? 32 : 0,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      gradient: widget.isActive ? AppColors.primaryGradient : null,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Icon with emoji overlay
                  SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Regular icon (fade out when active)
                        Opacity(
                          opacity: 1.0 - _activeAnim.value,
                          child: Icon(
                            widget.item.icon,
                            size: 24,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        // Active icon (fade in when active)
                        Opacity(
                          opacity: _activeAnim.value,
                          child: Icon(
                            widget.item.activeIcon,
                            size: 24 + (_activeAnim.value * 2),
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          widget.isActive ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'Quicksand',
                      color: widget.isActive
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    child: Text(widget.item.label),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
