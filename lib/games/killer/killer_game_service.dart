import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/repositories/best_scores_repository.dart';
import 'package:sudoku/core/services/index.dart';
import 'package:sudoku/games/killer/killer_repository.dart';
import 'package:sudoku/games/killer/models/index.dart';

/// 杀手数独游戏服务
///
/// 重构说明：
/// - 大部分逻辑已上移到 GameService 基类
/// - 仅实现持久化相关方法和 createGameState
/// - 使用统一的 GameValidator 处理验证
/// - 最佳成绩功能通过 bestScoresRepository getter 启用
class KillerGameService extends GameService {
  KillerGameService({
    KillerRepository? gameRepository,
    KillerBestScoresRepository? bestScoresRepository,
    GameValidator? validator,
  }) : _gameRepository = gameRepository ?? KillerRepository(),
       _bestScoresRepository =
           bestScoresRepository ?? KillerBestScoresRepository(),
       super(gameType: 'killer', validator: validator ?? GameValidator());
  final KillerRepository _gameRepository;
  final KillerBestScoresRepository _bestScoresRepository;

  @override
  BestScoresRepository? get bestScoresRepository => _bestScoresRepository;

  @override
  bool isGameCompleted(GameState state) {
    final board = state.board;
    
    if (!board.isComplete()) {
      return false;
    }
    
    if (board is KillerBoard) {
      return board.areAllCagesValid;
    }
    
    return true;
  }

  @override
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) {
    // 直接使用传入的 solution（已经是 KillerBoard，带有正确的笼子）
    final killerSolution = solution as KillerBoard;
    final killerPuzzle = _createEmptyKillerBoardWithCages(killerSolution);

    return KillerGameState(
      board: killerPuzzle,
      initialBoard: killerPuzzle,
      solution: killerSolution,
      difficulty: difficulty.name,
      startTime: DateTime.now(),
    );
  }

  /// 创建空的KillerBoard（只保留cages，清除所有数字）
  /// 杀手数独规则：不提供任何预先填好的数字
  KillerBoard _createEmptyKillerBoardWithCages(KillerBoard solutionBoard) {
    // 创建空的单元格（所有数字都为空）
    final emptyCells = List.generate(
      solutionBoard.size,
      (row) =>
          List.generate(solutionBoard.size, (col) => Cell(row: row, col: col)),
    );

    // 创建临时board来生成基础区域
    final tempBoard = KillerBoard(size: solutionBoard.size, cells: emptyCells);
    final regions = tempBoard.createRegions();

    return KillerBoard(
      size: solutionBoard.size,
      cells: emptyCells,
      regions: regions,
      cages: solutionBoard.cages,
    );
  }

  /// 保存游戏状态（使用基类签名）
  @override
  Future<void> saveGameState(GameState state) async {
    await _gameRepository.saveGameState(
      state as KillerGameState,
      '${gameType}_current',
    );
  }

  /// 加载游戏状态（使用基类签名）
  @override
  Future<GameState?> loadGameState(String gameId) async =>
      _gameRepository.loadGameState(gameId);

  /// 删除游戏状态（使用基类签名）
  @override
  Future<void> deleteGameState(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }

  /// 获取所有保存的游戏（使用基类签名）
  @override
  Future<List<GameState>> getAllSavedGames() async {
    final gamesData = await _gameRepository.getAllSavedGames();
    return gamesData
        .map((data) => KillerGameState.fromJson(data['data']))
        .toList();
  }

  /// 检查是否有保存的游戏（使用基类签名）
  @override
  Future<bool> hasSavedGame(String gameId) async =>
      _gameRepository.hasSavedGame(gameId);

  @override
  Future<void> clearSavedGame(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }
}
