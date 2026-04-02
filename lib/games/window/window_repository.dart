import 'package:sudoku/core/repositories/best_scores_repository.dart';
import 'package:sudoku/core/repositories/game_repository.dart';
import 'package:sudoku/games/window/models/window_game_state.dart';

/// Window 游戏仓库实现
///
/// 继承自 GameRepository，实现特定的序列化/反序列化逻辑
class WindowRepository extends GameRepository<WindowGameState> {
  @override
  WindowGameState fromJson(Map<String, dynamic> json) =>
      WindowGameState.fromJson(json);
}

/// Window 最佳成绩仓库实现
///
/// 继承自 BestScoresRepository，使用特定的存储键
class WindowBestScoresRepository extends BestScoresRepository {
  WindowBestScoresRepository() : super('window_best_scores');
}
