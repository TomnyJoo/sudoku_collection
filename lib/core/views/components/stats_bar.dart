import 'package:flutter/material.dart';
import 'package:sudoku/common/layout/responsive_layout.dart';
import 'package:sudoku/common/theme/theme_extension.dart';

class StatsBar extends StatelessWidget {

  const StatsBar({
    super.key,
    required this.elapsedTime,
    required this.mistakes,
    required this.difficulty,
  });
  final String elapsedTime;
  final int mistakes;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final responsiveBorderRadius = ResponsiveLayout.getResponsiveBorderRadius(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getResponsivePadding(context) * 0.8,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  context.primaryColor.withAlpha(51),
                  context.primaryColor.withAlpha(26),
                ]
              : [Colors.white.withAlpha(38), Colors.white.withAlpha(13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        border: Border.all(
          color: isDarkMode
              ? context.borderColor.withAlpha(102)
              : Colors.white.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, Icons.timer, elapsedTime, context.infoColor),
          _buildStatItem(context, Icons.warning_amber, mistakes.toString(), context.errorColor),
          _buildStatItem(context, Icons.star_half, difficulty, context.warningColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    final isDarkMode = context.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveLayout.getResponsiveFontSize(14, context),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class StatsRow extends StatelessWidget {

  const StatsRow({
    super.key,
    required this.elapsedTime,
    required this.mistakes,
    required this.difficulty,
  });
  final String elapsedTime;
  final int mistakes;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final responsiveBorderRadius = ResponsiveLayout.getResponsiveBorderRadius(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(180),
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        border: Border.all(color: Colors.grey.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(context, Icons.timer, elapsedTime, context.infoColor),
          const SizedBox(width: 16),
          _buildStatItem(context, Icons.warning_amber, mistakes.toString(), context.errorColor),
          const SizedBox(width: 16),
          _buildStatItem(context, Icons.star_half, difficulty, context.warningColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    final isDarkMode = context.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveLayout.getResponsiveFontSize(14, context),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
