import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/diagonal/models/diagonal_board.dart';
import 'package:sudoku/games/jigsaw/models/jigsaw_board.dart';
import 'package:sudoku/games/killer/models/killer_board.dart';
import 'package:sudoku/games/samurai/models/samurai_board.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import 'package:sudoku/games/window/models/window_board.dart';

/// 生成阶段
enum GenerationStage {
  initializing,  // 初始化
  loadingTemplate,  // 加载模板
  creatingRegions,  // 创建区域
  applyingSubstitution,  // 应用数字替换
  generatingSolution,  // 生成终盘
  diggingPuzzle,  // 挖空
  validating,  // 验证
  completed,  // 完成
}

/// 游戏生成结果
class GenerationResult {

  GenerationResult({
    required this.solution,
    required this.puzzle,
    required this.generationTime,
    this.usedTemplate = false,
  });

  /// 从 JSON 创建
  factory GenerationResult.fromJson(Map<String, dynamic> json) {
    final gameTypeStr = json['gameType'] as String;
    final puzzleData = json['puzzle'] as Map<String, dynamic>;
    final solutionData = json['solution'] as Map<String, dynamic>;
    
    // 提取类型名称（去掉可能的命名空间）
    final typeName = gameTypeStr.split('.').last;
    
    // 根据 gameType 创建对应的 Board
    Board puzzle;
    Board solution;
    
    switch (typeName) {
      case 'JigsawBoard':
        puzzle = JigsawBoard.fromJson(puzzleData);
        solution = JigsawBoard.fromJson(solutionData);
        break;
      case 'KillerBoard':
        puzzle = KillerBoard.fromJson(puzzleData);
        solution = KillerBoard.fromJson(solutionData);
        break;
      case 'DiagonalBoard':
        puzzle = DiagonalBoard.fromJson(puzzleData);
        solution = DiagonalBoard.fromJson(solutionData);
        break;
      case 'WindowBoard':
        puzzle = WindowBoard.fromJson(puzzleData);
        solution = WindowBoard.fromJson(solutionData);
        break;
      case 'SamuraiBoard':
        puzzle = SamuraiBoard.fromJson(puzzleData);
        solution = SamuraiBoard.fromJson(solutionData);
        break;
      default:
        puzzle = StandardBoard.fromJson(puzzleData);
        solution = StandardBoard.fromJson(solutionData);
        break;
    }
    
    return GenerationResult(
      puzzle: puzzle,
      solution: solution,
      generationTime: Duration(milliseconds: json['generationTimeMs'] as int),
      usedTemplate: json['usedTemplate'] as bool,
    );
  }
  final Board solution;
  final Board puzzle;
  final Duration generationTime;
  final bool usedTemplate;

  /// 转换为 JSON
  Map<String, dynamic> toJson() => {
      'puzzle': puzzle.toJson(),
      'solution': solution.toJson(),
      'generationTimeMs': generationTime.inMilliseconds,
      'usedTemplate': usedTemplate,
      'gameType': puzzle.runtimeType.toString(),
    };
}

/// 游戏生成器接口
/// 所有专用生成器必须实现此接口
abstract class IGameGenerator {
  /// 支持的游戏类型
  GameType get supportedGameType;

  /// 生成游戏
  /// [difficulty] - 难度等级
  /// [size] - 棋盘大小（通常为9）
  /// [isCancelled] - 取消回调函数
  /// [templateData] - 预加载的模板数据（可选）
  /// [onStageUpdate] - 生成阶段更新回调（可选）
  Future<GenerationResult> generate({
    required Difficulty difficulty,
    required int size,
    bool Function()? isCancelled,
    Map<String, dynamic>? templateData,
    Function(GenerationStage)? onStageUpdate,
  });
}

/// 挖空配置
class DiggingConfig {

  DiggingConfig({
    required this.minFilledCells,
    required this.maxFilledCells,
    this.maxAttempts = 10,
  });

  factory DiggingConfig.fromDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return DiggingConfig(minFilledCells: 40, maxFilledCells: 45);
      case Difficulty.easy:
        return DiggingConfig(minFilledCells: 35, maxFilledCells: 40);
      case Difficulty.medium:
        return DiggingConfig(minFilledCells: 30, maxFilledCells: 35, maxAttempts: 15);
      case Difficulty.hard:
        return DiggingConfig(minFilledCells: 25, maxFilledCells: 30, maxAttempts: 20);
      case Difficulty.expert:
        return DiggingConfig(minFilledCells: 22, maxFilledCells: 28, maxAttempts: 25);
      case Difficulty.master:
        return DiggingConfig(minFilledCells: 17, maxFilledCells: 25, maxAttempts: 30);
      case Difficulty.custom:
        return DiggingConfig(minFilledCells: 30, maxFilledCells: 40, maxAttempts: 20);
    }
  }
  final int minFilledCells;
  final int maxFilledCells;
  final int maxAttempts;
}
