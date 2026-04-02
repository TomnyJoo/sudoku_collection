import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/services/candidate_calculator.dart';
import 'package:sudoku/core/services/strategy/index.dart';
import 'package:sudoku/games/killer/models/killer_board.dart';

/// 策略服务（核心）
class StrategyService {
  StrategyService._();
  static final StrategyService instance = StrategyService._();
  
  /// 应用策略到棋盘上下文
  bool applyStrategies(
    BoardContext context,
    {
      bool enableXWing = true,
      bool enableSwordfish = true,
      bool enableHiddenTriples = true,
      bool enableLockedCandidate = true,
    }
  ) {
    // 确定游戏类型
    final GameType gameType = _detectGameType(context.board);
    
    final strategies = StrategyRegistry.getForGame(gameType);
    return StrategyExecutor.execute(context, strategies);
  }
  


  /// 检测游戏类型
  GameType _detectGameType(Board board) {
    if (board is KillerBoard) {
      return GameType.killer;
    }
    if (board.regions.any((r) => r.type == RegionType.diagonal)) {
      return GameType.diagonal;
    }
    if (board.regions.any((r) => r.type == RegionType.window)) {
      return GameType.window;
    }
    if (board.regions.any((r) => r.type == RegionType.jigsaw)) {
      return GameType.jigsaw;
    }
    if (board.size == 21) {
      return GameType.samurai;
    }
    return GameType.standard;
  }
  
  /// 初始化策略注册
  static void initialize() {
    // 注册基础策略（适用于所有数独类型，包括对角线和窗口数独）
    StrategyRegistry.register(const NakedSingleStrategy());
    StrategyRegistry.register(const HiddenSingleStrategy());
    
    // 注册杀手数独专用策略（在裸对、隐对等标准策略之前）
    StrategyRegistry.register(const KillerCageConstraintStrategy());
    StrategyRegistry.register(const Killer45RuleStrategy());
    StrategyRegistry.register(const KillerOverlapEliminationStrategy());
    StrategyRegistry.register(const KillerCageBlockingStrategy());
    
    // 注册其他标准策略
    StrategyRegistry.register(const NakedPairStrategy());
    StrategyRegistry.register(const HiddenPairStrategy());
    StrategyRegistry.register(const NakedTripleStrategy());
    StrategyRegistry.register(const HiddenTripleStrategy());
    StrategyRegistry.register(const LockedCandidateStrategy());
    StrategyRegistry.register(const XWingStrategy());
    StrategyRegistry.register(const SwordfishStrategy());
    

  }
}
