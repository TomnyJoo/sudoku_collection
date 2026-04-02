import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/diagonal_repository.dart';
import 'package:sudoku/games/diagonal/models/index.dart';

/// 对角线数独游戏服务
///
/// 重构说明：
/// - 大部分逻辑已上移到 GameService 基类
/// - 仅实现持久化相关方法和 createGameState
/// - 最佳成绩功能通过 bestScoresRepository getter 启用
class DiagonalGameService extends GameService {
  DiagonalGameService({
    DiagonalRepository? gameRepository,
    DiagonalBestScoresRepository? bestScoresRepository,
    GameValidator? validator,
  }) : _gameRepository = gameRepository ?? DiagonalRepository(),
       _bestScoresRepository =
           bestScoresRepository ?? DiagonalBestScoresRepository(),
       super(gameType: 'diagonal', validator: validator ?? GameValidator());
  final DiagonalRepository _gameRepository;
  final DiagonalBestScoresRepository _bestScoresRepository;

  @override
  BestScoresRepository? get bestScoresRepository => _bestScoresRepository;

  @override
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) => DiagonalGameState(
    board: puzzle as DiagonalBoard,
    initialBoard: puzzle,
    solution: solution as DiagonalBoard,
    difficulty: difficulty.name,
    startTime: DateTime.now(),
  );

  @override
  Future<void> saveGameState(GameState state) async {
    await _gameRepository.saveGameState(
      state as DiagonalGameState,
      '${gameType}_current',
    );
  }

  @override
  Future<GameState?> loadGameState(String saveKey) async =>
      _gameRepository.loadGameState(saveKey);

  @override
  Future<void> deleteGameState(String saveKey) async {
    await _gameRepository.clearGameState(saveKey);
  }

  @override
  Future<List<GameState>> getAllSavedGames() async {
    final gamesData = await _gameRepository.getAllSavedGames();
    return gamesData
        .map((data) => DiagonalGameState.fromJson(data['data']))
        .toList();
  }

  @override
  Future<bool> hasSavedGame(String saveKey) async =>
      _gameRepository.hasSavedGame(saveKey);

  @override
  Future<void> clearSavedGame(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }
}
