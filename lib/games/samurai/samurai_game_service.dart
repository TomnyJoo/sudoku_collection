import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/samurai/models/index.dart';
import 'package:sudoku/games/samurai/samurai_repository.dart';

/// 武士数独游戏服务
///
/// 优化说明：
/// - 移除重复实现的基类方法（setCellValue, undo, redo, updateTime等）
/// - 只保留持久化相关方法和 Samurai 特有的子网格切换方法
/// - 使用基类的 historyIndex 机制替代独立的 redoStack
class SamuraiGameService extends GameService {

  SamuraiGameService({
    SamuraiRepository? gameRepository,
    SamuraiBestScoresRepository? bestScoresRepository,
    GameValidator? validator,
  }) : _gameRepository = gameRepository ?? SamuraiRepository(),
       _bestScoresRepository = bestScoresRepository ?? SamuraiBestScoresRepository(),
       super(
         gameType: 'samurai',
         validator: validator ?? GameValidator(),
       );
  final SamuraiRepository _gameRepository;
  final SamuraiBestScoresRepository _bestScoresRepository;

  @override
  BestScoresRepository? get bestScoresRepository => _bestScoresRepository;

  @override
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) {
    final samuraiPuzzle = puzzle as SamuraiBoard;
    final samuraiSolution = solution as SamuraiBoard;
    return SamuraiGameState(
      board: samuraiPuzzle,
      initialBoard: samuraiPuzzle,
      solution: samuraiSolution,
      difficulty: difficulty,
      startTime: DateTime.now(),
    );
  }

  @override
  Future<void> saveGameState(GameState state) async {
    if (state is SamuraiGameState) {
      await _gameRepository.saveGameState(state, '${gameType}_current');
    }
  }

  @override
  Future<GameState?> loadGameState(String gameId) async => _gameRepository.loadGameState(gameId);

  @override
  Future<void> deleteGameState(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }

  @override
  Future<List<GameState>> getAllSavedGames() async {
    final gamesData = await _gameRepository.getAllSavedGames();
    return gamesData.map((data) => SamuraiGameState.fromJson(data['data'])).toList();
  }

  @override
  Future<bool> hasSavedGame(String gameId) async => _gameRepository.hasSavedGame(gameId);

  @override
  Future<void> clearSavedGame(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }
}
