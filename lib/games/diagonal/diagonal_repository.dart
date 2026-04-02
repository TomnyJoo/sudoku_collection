import 'package:sudoku/core/repositories/index.dart';
import 'package:sudoku/games/diagonal/models/diagonal_game_state.dart';

/// Diagonal 游戏仓库实现
/// 
/// 继承自 GameRepository，实现特定的序列化/反序列化逻辑
class DiagonalRepository extends GameRepository<DiagonalGameState> {
  @override
  DiagonalGameState fromJson(Map<String, dynamic> json) => DiagonalGameState.fromJson(json);
}

/// Diagonal 最佳成绩仓库实现
/// 
/// 继承自 BestScoresRepository，使用特定的存储键
class DiagonalBestScoresRepository extends BestScoresRepository {
  DiagonalBestScoresRepository() : super('diagonal_best_scores');
}
