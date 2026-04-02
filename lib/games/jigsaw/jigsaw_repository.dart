import 'package:sudoku/core/repositories/index.dart';
import 'package:sudoku/games/jigsaw/models/jigsaw_game_state.dart';

/// Jigsaw 游戏仓库实现
/// 
/// 继承自 GameRepository，实现特定的序列化/反序列化逻辑
class JigsawRepository extends GameRepository<JigsawGameState> {
  @override
  JigsawGameState fromJson(Map<String, dynamic> json) => JigsawGameState.fromJson(json);
}

/// Jigsaw 最佳成绩仓库实现
/// 
/// 继承自 BestScoresRepository，使用特定的存储键
class JigsawBestScoresRepository extends BestScoresRepository {
  JigsawBestScoresRepository() : super('jigsaw_best_scores');
}
