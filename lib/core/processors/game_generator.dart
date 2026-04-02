import 'package:sudoku/core/exceptions/exceptions.dart';
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/processors/game_generation_contracts.dart';
import 'package:sudoku/games/diagonal/diagonal_generator.dart';
import 'package:sudoku/games/jigsaw/jigsaw_generator.dart';
import 'package:sudoku/games/killer/killer_generator.dart';
import 'package:sudoku/games/samurai/samurai_generator.dart';
import 'package:sudoku/games/standard/standard_generator.dart';
import 'package:sudoku/games/window/window_generator.dart';

/// 游戏生成器统一入口
/// 
/// 此类作为游戏生成的统一接口，内部管理各专用生成器
class GameGenerator {

  GameGenerator();
  final Map<GameType, IGameGenerator> _generators = {};
  bool _initialized = false;

  /// 初始化生成器
  /// 注册所有游戏类型的专用生成器
  void initialize() {
    if (_initialized) return;

    _generators[GameType.standard] = StandardGenerator();
    _generators[GameType.diagonal] = DiagonalGenerator();
    _generators[GameType.window] = WindowGenerator();
    _generators[GameType.killer] = KillerGenerator();
    _generators[GameType.samurai] = SamuraiGenerator();
    _generators[GameType.jigsaw] = JigsawGenerator();

    _initialized = true;
  }

  /// 确保已初始化
  void _ensureInitialized() {
    if (!_initialized) {
      initialize();
    }
  }

  /// 生成游戏
  /// 
  /// [gameType] - 游戏类型
  /// [difficulty] - 难度等级
  /// [size] - 棋盘大小（通常为9）
  /// [isCancelled] - 取消回调函数
  /// [onStageUpdate] - 生成阶段更新回调
  /// [templateData] - 预加载的模板数据（可选）
  Future<GenerationResult> generate({
    required GameType gameType,
    required Difficulty difficulty,
    required int size,
    bool Function()? isCancelled,
    Function(GenerationStage)? onStageUpdate,
    Map<String, dynamic>? templateData,
  }) async {
    _ensureInitialized();

    final generator = _generators[gameType];
    if (generator == null) {
      throw GameGenerationException('不支持的游戏类型: $gameType');
    }

    return generator.generate(
      difficulty: difficulty,
      size: size,
      isCancelled: isCancelled,
      onStageUpdate: onStageUpdate,
      templateData: templateData,
    );
  }

  /// 销毁生成器
  void dispose() {
    _generators.clear();
    _initialized = false;
  }
}
