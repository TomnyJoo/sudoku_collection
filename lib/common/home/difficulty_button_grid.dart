import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

/// 难度选择卡片
class DifficultyButtonGrid extends StatelessWidget {
  const DifficultyButtonGrid({
    required this.gameType,
    required this.onDifficultySelected,
    this.isCompact = false,
    this.baseColor,
    super.key,
  });
  
  // ========== 变量 ==========
  final GameType gameType;
  final void Function(Difficulty) onDifficultySelected;
  final bool isCompact;
  final Color? baseColor;

  // ========== 方法 ==========
  @override
  Widget build(BuildContext context) {
    final difficulties = DifficultyExtension.allLevels
        .where((d) => d != Difficulty.custom)
        .toList();

    if (isCompact) {
      return _buildCompactLayout(context, difficulties);
    }
    return _buildStandardLayout(context, difficulties);
  }

  /// 构建紧凑布局的难度选择面板
  Widget _buildCompactLayout(BuildContext context, List<Difficulty> difficulties) => Wrap(
      spacing: 3,
      runSpacing: 3,
      alignment: WrapAlignment.center,
      children: difficulties
          .map((d) => _buildCompactButton(context, d))
          .toList(),
    );

  /// 构建标准布局的难度选择面板
  Widget _buildStandardLayout(BuildContext context, List<Difficulty> difficulties) => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: difficulties.take(3).map((d) => 
            Expanded(child: _buildButton(context, d))).toList(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: difficulties.skip(3).map((d) => 
            Expanded(child: _buildButton(context, d))).toList(),
        ),
      ],
    );

  /// 构建紧凑布局的难度按钮
  Widget _buildCompactButton(BuildContext context, Difficulty difficulty) {
    final localizations = LocalizationUtils.of(context);
    final label = _getDifficultyLabel(difficulty, localizations);
    
    return GestureDetector(
      onTap: () => onDifficultySelected(difficulty),
      child: Container(
        width: 42,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white.withAlpha(60),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 构建标准布局的难度按钮
  Widget _buildButton(BuildContext context, Difficulty difficulty) {
    final localizations = LocalizationUtils.of(context);
    final label = _getDifficultyLabel(difficulty, localizations);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () => onDifficultySelected(difficulty),
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withAlpha(60),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// 获取难度标签
  String _getDifficultyLabel(Difficulty difficulty, dynamic localizations) {
    if (localizations != null) {
      switch (difficulty) {
        case Difficulty.beginner:
          return localizations.difficultyBeginner ?? '入门';
        case Difficulty.easy:
          return localizations.difficultyEasy ?? '简单';
        case Difficulty.medium:
          return localizations.difficultyMedium ?? '中等';
        case Difficulty.hard:
          return localizations.difficultyHard ?? '困难';
        case Difficulty.expert:
          return localizations.difficultyExpert ?? '专家';
        case Difficulty.master:
          return localizations.difficultyMaster ?? '大师';
        case Difficulty.custom:
          return localizations.difficultyCustom ?? '自定义';
      }
    }
    return difficulty.displayName;
  }
}
