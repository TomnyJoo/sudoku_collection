import 'package:flutter/material.dart';
import 'package:sudoku/common/l10n/localization_utils.dart';
import 'package:sudoku/core/models/difficulty.dart';
import 'package:sudoku/core/processors/game_generation_contracts.dart';

/// 游戏工具类
/// 
/// 提供游戏相关的工具方法，包括进度文本获取、难度转换、时间格式化等
class GameUtils {
  /// 获取生成阶段的进度文本
  /// 
  /// [generationStage] 生成阶段
  /// 
  /// 返回对应阶段的进度文本
  static String? getProgressText(dynamic generationStage) {
    if (generationStage is GenerationStage) {
      switch (generationStage) {
        case GenerationStage.initializing:
          return '正在初始化';
        case GenerationStage.loadingTemplate:
          return '正在加载模板';
        case GenerationStage.creatingRegions:
          return '正在创建区域';
        case GenerationStage.applyingSubstitution:
          return '正在应用数字替换';
        case GenerationStage.generatingSolution:
          return '正在生成终盘';
        case GenerationStage.diggingPuzzle:
          return '正在生成棋盘';
        case GenerationStage.validating:
          return '正在验证棋盘';
        case GenerationStage.completed:
          return '生成完成';
      }
    }
    return null;
  }

  /// 从标识符获取难度
  /// 
  /// [identifier] 难度标识符
  /// 
  /// 返回对应的难度枚举
  static Difficulty? getDifficultyFromIdentifier(String identifier) =>
      DifficultyExtension.fromIdentifier(identifier);

  /// 格式化时间（秒）为分:秒格式
  /// 
  /// [seconds] 秒数
  /// 
  /// 返回格式化后的时间字符串
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 获取本地化的难度名称
  /// 
  /// [context] 构建上下文
  /// [difficulty] 难度（可以是Difficulty枚举或字符串标识符）
  /// 
  /// 返回本地化的难度名称
  static String getLocalizedDifficultyName(
    BuildContext context,
    dynamic difficulty,
  ) {
    Difficulty? difficultyEnum;

    if (difficulty is Difficulty) {
      difficultyEnum = difficulty;
    } else if (difficulty is String) {
      difficultyEnum = getDifficultyFromIdentifier(difficulty);
    }

    if (difficultyEnum == null) {
      return difficulty.toString();
    }

    final loc = LocalizationUtils.of(context);
    switch (difficultyEnum) {
      case Difficulty.beginner:
        return loc?.difficultyBeginner ?? 'Beginner';
      case Difficulty.easy:
        return loc?.difficultyEasy ?? 'Easy';
      case Difficulty.medium:
        return loc?.difficultyMedium ?? 'Medium';
      case Difficulty.hard:
        return loc?.difficultyHard ?? 'Hard';
      case Difficulty.expert:
        return loc?.difficultyExpert ?? 'Expert';
      case Difficulty.master:
        return loc?.difficultyMaster ?? 'Master';
      case Difficulty.custom:
        return loc?.difficultyCustom ?? 'Custom';
    }
  }
  
  /// 计算游戏完成百分比
  /// 
  /// [filledCells] 已填充的单元格数量
  /// [totalCells] 总单元格数量
  /// 
  /// 返回完成百分比（0-100）
  static int calculateCompletionPercentage(int filledCells, int totalCells) {
    if (totalCells == 0) return 0;
    return (filledCells / totalCells * 100).round();
  }
  
  /// 生成游戏难度描述
  /// 
  /// [difficulty] 难度
  /// 
  /// 返回难度描述文本
  static String getDifficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return '适合初学者，填入数字较少';
      case Difficulty.easy:
        return '简单难度，有基本逻辑就能解决';
      case Difficulty.medium:
        return '中等难度，需要一些技巧';
      case Difficulty.hard:
        return '困难难度，需要高级技巧';
      case Difficulty.expert:
        return '专家难度，挑战你的极限';
      case Difficulty.master:
        return '大师难度，只有真正的数独高手才能完成';
      case Difficulty.custom:
        return '自定义难度';
    }
  }
}
