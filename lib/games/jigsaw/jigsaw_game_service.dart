import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/repositories/index.dart';
import 'package:sudoku/core/services/index.dart';
import 'package:sudoku/games/jigsaw/jigsaw_repository.dart';
import 'package:sudoku/games/jigsaw/models/jigsaw_game_state.dart';

/// 锯齿数独游戏服务
///
/// 重构说明：
/// - 大部分逻辑已上移到 GameService 基类
/// - 仅实现持久化相关方法和 createGameState
/// - 最佳成绩功能通过 bestScoresRepository getter 启用
class JigsawGameService extends GameService {
  
  JigsawGameService({
    JigsawRepository? gameRepository,
    JigsawBestScoresRepository? bestScoresRepository,
    GameValidator? validator,
  }) : _gameRepository = gameRepository ?? JigsawRepository(),
       _bestScoresRepository = bestScoresRepository ?? JigsawBestScoresRepository(),
       super(
         gameType: 'jigsaw',
         validator: validator ?? GameValidator(),
       );
  final JigsawRepository _gameRepository;
  final JigsawBestScoresRepository _bestScoresRepository;

  @override
  BestScoresRepository? get bestScoresRepository => _bestScoresRepository;

  @override
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) => JigsawGameState(
      board: puzzle,
      initialBoard: puzzle,
      solution: solution,
      difficulty: difficulty.name,
      startTime: DateTime.now(),
    );

  @override
  Future<void> saveGameState(GameState gameState) async {
    await _gameRepository.saveGameState(gameState as JigsawGameState, '${gameType}_current');
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
    return gamesData.map((data) => JigsawGameState.fromJson(data['data'])).toList();
  }
  
  @override
  Future<bool> hasSavedGame(String saveKey) async => _gameRepository.hasSavedGame(saveKey);

  @override
  Future<void> clearSavedGame(String gameId) async {
    await _gameRepository.clearGameState(gameId);
  }
}
