import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/services/strategy/strategy_interface.dart';

/// 策略注册表
class StrategyRegistry {
  static final Map<StrategyType, Strategy> _strategies = {};

  static void register(Strategy strategy) {
    _strategies[strategy.type] = strategy;
  }

  static Strategy? get(StrategyType type) => _strategies[type];

  /// 获取所有已注册的策略
  static List<Strategy> getAllStrategies() => _strategies.values.toList();

  static List<Strategy> getForGame(GameType gameType) => _strategies.values
      .where((s) => s.applicableGames.contains(gameType))
      .toList()
      ..sort((a, b) => a.level.index.compareTo(b.level.index));

  static List<Strategy> getForLevel(StrategyLevel maxLevel) =>
      _strategies.values
          .where((s) => s.level.index <= maxLevel.index)
          .toList()
          ..sort((a, b) => a.level.index.compareTo(b.level.index));

  static List<Strategy> getForGameAndLevel(
    GameType gameType,
    StrategyLevel maxLevel,
  ) => _strategies.values
      .where(
        (s) =>
            s.applicableGames.contains(gameType) &&
            s.level.index <= maxLevel.index,
      )
      .toList()
      ..sort((a, b) => a.level.index.compareTo(b.level.index));
}
