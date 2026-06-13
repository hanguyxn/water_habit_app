import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/features/profile/domain/profile_model.dart';

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({
    super.key,
    required this.data,
  });

  final List<WeeklyWaterData> data;

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _barAnimation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? null : AppColors.natureShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _barAnimation,
              builder: (context, _) => _buildChart(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    // Calculate weekly average
    double totalMl = 0;
    int activeDays = 0;
    for (final d in widget.data) {
      if (d.amountMl > 0) {
        totalMl += d.amountMl;
        activeDays++;
      }
    }
    final avgMl = activeDays > 0 ? totalMl / activeDays : 0.0;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('📊', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '7 ngày gần đây',
                style: TextStyle(
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                'Trung bình: ${(avgMl / 1000).toStringAsFixed(1)}L/ngày',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textOnDark.withValues(alpha: 0.6)
                      : AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(bool isDark) {
    if (widget.data.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(
            color: isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textHint,
            fontFamily: 'Quicksand',
          ),
        ),
      );
    }

    final maxGoal = widget.data
        .map((d) => d.goalMl)
        .reduce((a, b) => a > b ? a : b);
    final maxAmount = widget.data
        .map((d) => d.amountMl)
        .reduce((a, b) => a > b ? a : b);
    final maxY = ((maxGoal > maxAmount ? maxGoal : maxAmount) * 1.2);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = widget.data[group.x.toInt()];
              return BarTooltipItem(
                '${(entry.amountMl / 1000).toStringAsFixed(1)}L\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Nunito',
                ),
                children: [
                  TextSpan(
                    text: '${(entry.amountMl / entry.goalMl * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= widget.data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.data[index].dayLabel,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.6)
                          : AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${(value / 1000).toStringAsFixed(1)}',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textOnDark.withValues(alpha: 0.4)
                        : AppColors.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.5)
                  : AppColors.border.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(isDark),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: widget.data.isNotEmpty ? widget.data.first.goalMl : 2500,
              color: AppColors.accent.withValues(alpha: 0.6),
              strokeWidth: 2,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: TextStyle(
                  color: isDark
                      ? AppColors.accentLight
                      : AppColors.accentDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Quicksand',
                ),
                labelResolver: (_) => 'Mục tiêu',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(bool isDark) {
    return List.generate(widget.data.length, (index) {
      final entry = widget.data[index];
      final isTouched = _touchedIndex == index;
      final ratio = entry.goalMl > 0 ? entry.amountMl / entry.goalMl : 0.0;

      Color barColor;
      List<Color> gradientColors;
      if (ratio >= 1.0) {
        // Completed - green
        barColor = AppColors.primaryLight;
        gradientColors = [AppColors.primary, AppColors.primaryLight];
      } else if (ratio > 0) {
        // Partial - blue
        barColor = AppColors.accent;
        gradientColors = [AppColors.accentDark, AppColors.accent];
      } else {
        // Missed - grey
        barColor = AppColors.disabled;
        gradientColors = [AppColors.disabled, AppColors.shimmerBase];
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.amountMl * _barAnimation.value,
            color: barColor,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: gradientColors,
            ),
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: entry.goalMl.toDouble(),
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.disabledBackground,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Đạt mục tiêu', AppColors.primaryLight, isDark),
        const SizedBox(width: 16),
        _buildLegendItem('Đang uống', AppColors.accent, isDark),
        const SizedBox(width: 16),
        _buildLegendItem('Bỏ lỡ', AppColors.disabled, isDark),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textOnDark.withValues(alpha: 0.6)
                : AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);
}
