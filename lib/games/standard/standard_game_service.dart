import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/repositories/best_scores_repository.dart';
import 'package:sudoku/core/services/index.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import 'package:sudoku/games/standard/models/standard_game_state.dart';
import 'package:sudoku/games/standard/standard_repository.dart';

/// 标准数独游戏服务
///
/// 重构说明：
/// - 大部分逻辑已上移到 GameService 基类
/// - 仅实现持久化相关方法和 createGameState
/// - 最佳成绩功能通过 bestScoresRepository getter 启用
class StandardGameService extends GameService {
  StandardGameService({
    StandardRepository? gameRepository,
    StandardBestScoresRepository? bestScoresRepository,
  }) : _gameRepository = gameRepository ?? StandardRepository(),
       _bestScoresRepository =
           bestScoresRepository ?? StandardBestScoresRepository(),
       super(gameType: 'standard', validator: GameValidator());
  final StandardRepository _gameRepository;
  final StandardBestScoresRepository _bestScoresRepository;

  @override
  BestScoresRepository? get bestScoresRepository => _bestScoresRepository;

  @override
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) {
    final standardPuzzle = puzzle as StandardBoard;
    final standardSolution = solution as StandardBoard;

    // 确保 puzzle 有 regions
    final puzzleWithRegions = standardPuzzle.regions.isEmpty
        ? StandardBoard(
            size: standardPuzzle.size,
            cells: standardPuzzle.cells,
            regions: standardPuzzle.createRegions(),
          )
        : standardPuzzle;

    // 确保 solution 有 regions
    final solutionWithRegions = standardSolution.regions.isEmpty
        ? StandardBoard(
            size: standardSolution.size,
            cells: standardSolution.cells,
            regions: standardSolution.createRegions(),
          )
        : standardSolution;

    return StandardGameState(
      board: puzzleWithRegions,
      initialBoard: puzzleWithRegions,
      solution: solutionWithRegions,
      difficulty: difficulty.name,
      startTime: DateTime.now(),
    );
  }

  @override
  Future<void> saveGameState(GameState state) async {
    await _gameRepository.saveGameState(
      state as StandardGameState,
      '${gameType}_current',
    );
  }

  @override
  Future<GameState?> loadGameState(String gameId) async =>
      _gameRepository.loadGameState(gameId);

  @override
  Future<void> deleteGameState(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }

  @override
  Future<List<GameState>> getAllSavedGames() async {
    final gamesData = await _gameRepository.getAllSavedGames();
    return gamesData
        .map((data) => StandardGameState.fromJson(data['data']))
        .toList();
  }

  @override
  Future<bool> hasSavedGame(String gameId) async =>
      _gameRepository.hasSavedGame(gameId);

  @override
  Future<void> clearSavedGame(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }
}
