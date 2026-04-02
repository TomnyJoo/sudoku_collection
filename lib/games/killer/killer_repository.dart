import 'package:sudoku/core/repositories/best_scores_repository.dart';
import 'package:sudoku/core/repositories/game_repository.dart';
import 'package:sudoku/games/killer/models/killer_game_state.dart';

/// 杀手数独游戏仓库
/// 
/// 继承自 GameRepository，实现特定的序列化/反序列化逻辑
class KillerRepository extends GameRepository<KillerGameState> {
  @override
  KillerGameState fromJson(Map<String, dynamic> json) => KillerGameState.fromJson(json);
}

/// 杀手数独最佳成绩仓库
/// 
/// 继承自 BestScoresRepository，使用特定的存储键
class KillerBestScoresRepository extends BestScoresRepository {
  KillerBestScoresRepository() : super('killer_best_scores');
}
