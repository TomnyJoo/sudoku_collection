import 'package:sudoku/core/repositories/best_scores_repository.dart';
import 'package:sudoku/core/repositories/game_repository.dart';
import 'package:sudoku/games/samurai/models/samurai_game_state.dart';

/// 武士数独游戏仓库实现
/// 
/// 继承自 GameRepository，实现特定的序列化/反序列化逻辑
class SamuraiRepository extends GameRepository<SamuraiGameState> {
  @override
  SamuraiGameState fromJson(Map<String, dynamic> json) => SamuraiGameState.fromJson(json);
}

/// 武士数独最佳成绩仓库实现
/// 
/// 继承自 BestScoresRepository，使用特定的存储键
class SamuraiBestScoresRepository extends BestScoresRepository {
  SamuraiBestScoresRepository() : super('samurai_best_scores');
}
