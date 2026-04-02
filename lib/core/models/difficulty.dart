import 'dart:math';
import 'package:sudoku/core/models/game_type.dart';
import 'package:sudoku/core/models/strategy.dart';

/// 数独难度等级枚举
enum Difficulty { beginner, easy, medium, hard, expert, master, custom }

/// 游戏类型特定配置
class GameTypeDifficultyConfig {
  const GameTypeDifficultyConfig({
    required this.gameType,
    required this.minFilledCells,
    required this.maxFilledCells,
    required this.minStrategyLevel,
    required this.maxStrategyLevel,
    this.requiredStrategies = const [],
  });
  final GameType gameType;
  final int minFilledCells;
  final int maxFilledCells;
  final StrategyLevel minStrategyLevel;
  final StrategyLevel maxStrategyLevel;
  final List<StrategyType> requiredStrategies;

  bool get isValid =>
      minFilledCells >= 0 &&
      maxFilledCells <= 81 &&
      minFilledCells <= maxFilledCells;

  @override
  String toString() =>
      'GameTypeDifficultyConfig(gameType: $gameType, filled: $minFilledCells-$maxFilledCells, level: $minStrategyLevel-$maxStrategyLevel)';
}

/// 难度级别配置（包含每个难度级别的具体配置参数）
class DifficultyConfig {
  const DifficultyConfig({
    required this.level,
    required this.name,
    required this.maxStrategyLevel,
    required this.gameTypeConfigs,
    required this.difficultyScore,
    required this.minExpectedTime,
    required this.maxExpectedTime,
  });
  static final Random _random = Random();

  final Difficulty level;
  final String name;
  final StrategyLevel maxStrategyLevel;
  final Map<GameType, GameTypeDifficultyConfig> gameTypeConfigs;
  final double difficultyScore;
  final int minExpectedTime;
  final int maxExpectedTime;

  GameTypeDifficultyConfig getGameConfig(GameType gameType) =>
      gameTypeConfigs[gameType] ?? gameTypeConfigs[GameType.standard]!;

  static List<DifficultyConfig> getAllConfigs() => [
    const DifficultyConfig(
      level: Difficulty.beginner,
      name: '入门',
      maxStrategyLevel: StrategyLevel.basic,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 45,
          maxFilledCells: 55,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.basic,
        ),
        GameType.diagonal: GameTypeDifficultyConfig(
          gameType: GameType.diagonal,
          minFilledCells: 47,
          maxFilledCells: 57,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.basic,
        ),
        GameType.window: GameTypeDifficultyConfig(
          gameType: GameType.window,
          minFilledCells: 48,
          maxFilledCells: 58,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.basic,
        ),
      },
      difficultyScore: 0.1,
      minExpectedTime: 300,
      maxExpectedTime: 600,
    ),
    const DifficultyConfig(
      level: Difficulty.easy,
      name: '简单',
      maxStrategyLevel: StrategyLevel.intermediate,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 38,
          maxFilledCells: 45,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.intermediate,
        ),
        GameType.diagonal: GameTypeDifficultyConfig(
          gameType: GameType.diagonal,
          minFilledCells: 40,
          maxFilledCells: 47,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.intermediate,
        ),
        GameType.window: GameTypeDifficultyConfig(
          gameType: GameType.window,
          minFilledCells: 42,
          maxFilledCells: 48,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.intermediate,
        ),
      },
      difficultyScore: 0.3,
      minExpectedTime: 600,
      maxExpectedTime: 1200,
    ),
    const DifficultyConfig(
      level: Difficulty.medium,
      name: '中等',
      maxStrategyLevel: StrategyLevel.intermediate,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 32,
          maxFilledCells: 38,
          minStrategyLevel: StrategyLevel.intermediate,
          maxStrategyLevel: StrategyLevel.intermediate,
        ),
        GameType.diagonal: GameTypeDifficultyConfig(
          gameType: GameType.diagonal,
          minFilledCells: 34,
          maxFilledCells: 40,
          minStrategyLevel: StrategyLevel.intermediate,
          maxStrategyLevel: StrategyLevel.intermediate,
        ),
        GameType.window: GameTypeDifficultyConfig(
          gameType: GameType.window,
          minFilledCells: 36,
          maxFilledCells: 42,
          minStrategyLevel: StrategyLevel.intermediate,
          maxStrategyLevel: StrategyLevel.intermediate,
        ),
      },
      difficultyScore: 0.5,
      minExpectedTime: 1200,
      maxExpectedTime: 1800,
    ),
    const DifficultyConfig(
      level: Difficulty.hard,
      name: '困难',
      maxStrategyLevel: StrategyLevel.advanced,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 26,
          maxFilledCells: 32,
          minStrategyLevel: StrategyLevel.intermediate,
          maxStrategyLevel: StrategyLevel.advanced,
        ),
        GameType.diagonal: GameTypeDifficultyConfig(
          gameType: GameType.diagonal,
          minFilledCells: 28,
          maxFilledCells: 34,
          minStrategyLevel: StrategyLevel.intermediate,
          maxStrategyLevel: StrategyLevel.advanced,
        ),
        GameType.window: GameTypeDifficultyConfig(
          gameType: GameType.window,
          minFilledCells: 30,
          maxFilledCells: 36,
          minStrategyLevel: StrategyLevel.intermediate,
          maxStrategyLevel: StrategyLevel.advanced,
        ),
      },
      difficultyScore: 0.7,
      minExpectedTime: 1800,
      maxExpectedTime: 2700,
    ),
    const DifficultyConfig(
      level: Difficulty.expert,
      name: '专家',
      maxStrategyLevel: StrategyLevel.expert,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 22,
          maxFilledCells: 26,
          minStrategyLevel: StrategyLevel.advanced,
          maxStrategyLevel: StrategyLevel.expert,
        ),
        GameType.diagonal: GameTypeDifficultyConfig(
          gameType: GameType.diagonal,
          minFilledCells: 24,
          maxFilledCells: 28,
          minStrategyLevel: StrategyLevel.advanced,
          maxStrategyLevel: StrategyLevel.expert,
        ),
        GameType.window: GameTypeDifficultyConfig(
          gameType: GameType.window,
          minFilledCells: 26,
          maxFilledCells: 30,
          minStrategyLevel: StrategyLevel.advanced,
          maxStrategyLevel: StrategyLevel.expert,
        ),
      },
      difficultyScore: 0.85,
      minExpectedTime: 2700,
      maxExpectedTime: 3600,
    ),
    const DifficultyConfig(
      level: Difficulty.master,
      name: '大师',
      maxStrategyLevel: StrategyLevel.master,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 17,
          maxFilledCells: 22,
          minStrategyLevel: StrategyLevel.expert,
          maxStrategyLevel: StrategyLevel.master,
        ),
        GameType.diagonal: GameTypeDifficultyConfig(
          gameType: GameType.diagonal,
          minFilledCells: 19,
          maxFilledCells: 24,
          minStrategyLevel: StrategyLevel.expert,
          maxStrategyLevel: StrategyLevel.master,
        ),
        GameType.window: GameTypeDifficultyConfig(
          gameType: GameType.window,
          minFilledCells: 22,
          maxFilledCells: 26,
          minStrategyLevel: StrategyLevel.expert,
          maxStrategyLevel: StrategyLevel.master,
        ),
      },
      difficultyScore: 1.0,
      minExpectedTime: 3600,
      maxExpectedTime: 5400,
    ),
    const DifficultyConfig(
      level: Difficulty.custom,
      name: '自定义',
      maxStrategyLevel: StrategyLevel.master,
      gameTypeConfigs: {
        GameType.standard: GameTypeDifficultyConfig(
          gameType: GameType.standard,
          minFilledCells: 0,
          maxFilledCells: 81,
          minStrategyLevel: StrategyLevel.basic,
          maxStrategyLevel: StrategyLevel.master,
        ),
      },
      difficultyScore: 0.0,
      minExpectedTime: 0,
      maxExpectedTime: 0,
    ),
  ];

  static DifficultyConfig getConfig(final Difficulty level) =>
      getAllConfigs().firstWhere(
        (final config) => config.level == level,
        orElse: () => throw ArgumentError('未知的难度级别: $level'),
      );

  static DifficultyConfig getConfigByName(final String name) =>
      getAllConfigs().firstWhere(
        (final config) => config.name == name,
        orElse: () => throw ArgumentError('未知的难度名称: $name'),
      );

  static int getRandomFilledCount(
    final Difficulty level, {
    GameType gameType = GameType.standard,
  }) {
    final config = getConfig(level);
    final gameConfig = config.getGameConfig(gameType);
    final range = gameConfig.maxFilledCells - gameConfig.minFilledCells + 1;
    final random = _random.nextInt(range);
    return gameConfig.minFilledCells + random;
  }

  bool get isValid =>
      difficultyScore >= 0.0 &&
      difficultyScore <= 1.0 &&
      minExpectedTime >= 0 &&
      maxExpectedTime >= minExpectedTime;

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is DifficultyConfig && other.level == level;
  }

  @override
  int get hashCode => level.hashCode;

  String toDebugString() =>
      'DifficultyConfig(level: $level, name: $name, '
      'maxStrategyLevel: $maxStrategyLevel, score: $difficultyScore)';

  String toDisplayString({final dynamic localizations}) {
    final difficultyName = _getLocalizedDifficultyName(localizations);
    final difficultyScoreText = _getLocalizedDifficultyScoreText(localizations);
    final expectedTimeText = _getLocalizedExpectedTimeText(localizations);

    return '$difficultyName - $difficultyScoreText, $expectedTimeText';
  }

  String _getLocalizedDifficultyName(final dynamic localizations) {
    try {
      if (localizations is Map) {
        switch (level) {
          case Difficulty.beginner:
            return localizations['difficultyBeginner'] ?? name;
          case Difficulty.easy:
            return localizations['difficultyEasy'] ?? name;
          case Difficulty.medium:
            return localizations['difficultyMedium'] ?? name;
          case Difficulty.hard:
            return localizations['difficultyHard'] ?? name;
          case Difficulty.expert:
            return localizations['difficultyExpert'] ?? name;
          case Difficulty.master:
            return localizations['difficultyMaster'] ?? name;
          case Difficulty.custom:
            return localizations['difficultyCustom'] ?? name;
        }
      }
    } catch (e) {
      // 本地化获取失败时使用默认名称
    }
    return name;
  }

  String _getLocalizedDifficultyScoreText(final dynamic localizations) {
    const difficultyScoreKey = 'difficultyScore';

    try {
      if (localizations is Map) {
        final difficultyScoreText = localizations[difficultyScoreKey] ?? '难度系数';
        return '$difficultyScoreText: ${(difficultyScore * 100).toInt()}%';
      }
    } catch (e) {
      // 本地化获取失败时使用默认文本
    }
    return '难度系数: ${(difficultyScore * 100).toInt()}%';
  }

  String _getLocalizedExpectedTimeText(final dynamic localizations) {
    const expectedTimeKey = 'expectedTime';
    const unlimitedTimeKey = 'unlimitedTime';

    try {
      if (localizations is Map) {
        final expectedTimeText = localizations[expectedTimeKey] ?? '预计时间';
        final unlimitedTimeText = localizations[unlimitedTimeKey] ?? '时间不限';

        if (minExpectedTime > 0 && maxExpectedTime > 0) {
          return '$expectedTimeText: ${_formatTime(minExpectedTime)}-${_formatTime(maxExpectedTime)}';
        } else {
          return unlimitedTimeText;
        }
      }
    } catch (e) {
      // 本地化获取失败时使用默认文本
    }

    if (minExpectedTime > 0 && maxExpectedTime > 0) {
      return '预计时间: ${_formatTime(minExpectedTime)}-${_formatTime(maxExpectedTime)}';
    } else {
      return '时间不限';
    }
  }

  String _formatTime(final int seconds) {
    if (seconds < 60) {
      return '$seconds秒';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '$minutes分钟';
    }
    return '$minutes分$remainingSeconds秒';
  }

  @override
  String toString() => toDebugString();
}

extension DifficultyExtension on Difficulty {
  static List<Difficulty> get allLevels => [
    Difficulty.beginner,
    Difficulty.easy,
    Difficulty.medium,
    Difficulty.hard,
    Difficulty.expert,
    Difficulty.master,
    Difficulty.custom,
  ];

  String get identifier => toString();

  DifficultyConfig get config => DifficultyConfig.getConfig(this);

  String get displayName => config.name;

  String get iconName {
    switch (this) {
      case Difficulty.beginner:
        return 'beginner_icon';
      case Difficulty.easy:
        return 'easy_icon';
      case Difficulty.medium:
        return 'medium_icon';
      case Difficulty.hard:
        return 'hard_icon';
      case Difficulty.expert:
        return 'expert_icon';
      case Difficulty.master:
        return 'master_icon';
      case Difficulty.custom:
        return 'custom_icon';
    }
  }

  static Difficulty fromIdentifier(final String identifier) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.name == identifier) {
        return difficulty;
      }
    }
    for (final difficulty in Difficulty.values) {
      if (difficulty.identifier == identifier) {
        return difficulty;
      }
    }
    return Difficulty.values.firstWhere(
      (d) => d.toString() == identifier,
      orElse: () => Difficulty.medium,
    );
  }
}
