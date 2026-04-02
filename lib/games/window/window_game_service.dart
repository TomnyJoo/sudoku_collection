import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/repositories/index.dart';
import 'package:sudoku/core/services/index.dart';
import 'package:sudoku/games/window/models/index.dart';
import 'package:sudoku/games/window/window_repository.dart';

/// 窗口数独游戏服务
///
/// 重构说明：
/// - 大部分逻辑已上移到 GameService 基类
/// - 仅实现持久化相关方法和 createGameState
/// - 最佳成绩功能通过 bestScoresRepository getter 启用
class WindowGameService extends GameService {
  WindowGameService({
    WindowRepository? gameRepository,
    WindowBestScoresRepository? bestScoresRepository,
  }) : _gameRepository = gameRepository ?? WindowRepository(),
       _bestScoresRepository =
           bestScoresRepository ?? WindowBestScoresRepository(),
       super(gameType: 'window', validator: GameValidator());
  final WindowRepository _gameRepository;
  final WindowBestScoresRepository _bestScoresRepository;

  @override
  BestScoresRepository? get bestScoresRepository => _bestScoresRepository;

  @override
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) => WindowGameState(
    board: puzzle as WindowBoard,
    initialBoard: puzzle,
    solution: solution as WindowBoard,
    difficulty: difficulty.name,
    startTime: DateTime.now(),
  );

  @override
  Future<void> saveGameState(GameState state) async {
    await _gameRepository.saveGameState(
      state as WindowGameState,
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
        .map((data) => WindowGameState.fromJson(data['data']))
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
