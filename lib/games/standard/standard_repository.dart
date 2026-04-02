import 'package:sudoku/core/repositories/index.dart';
import 'package:sudoku/games/standard/models/standard_game_state.dart';

/// Standard 游戏仓库实现
/// 
/// 继承自 GameRepository，实现特定的序列化/反序列化逻辑
class StandardRepository extends GameRepository<StandardGameState> {
  @override
  StandardGameState fromJson(Map<String, dynamic> json) => StandardGameState.fromJson(json);
}

/// Standard 最佳成绩仓库实现
/// 
/// 继承自 BestScoresRepository，使用特定的存储键
class StandardBestScoresRepository extends BestScoresRepository {
  StandardBestScoresRepository() : super('standard_best_scores');
}
