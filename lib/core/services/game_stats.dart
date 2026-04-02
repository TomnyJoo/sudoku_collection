import 'package:sudoku/core/models/index.dart';

/// 游戏统计计算器
/// 负责计算游戏的各种统计数据
class GameStats {
  /// 获取游戏完成百分比
  double getCompletionPercentage(GameState gameState) {
    final board = gameState.board;
    final filledCount = board.getFilledCells().length;
    final totalCount = board.size * board.size;
    return filledCount / totalCount;
  }

  /// 获取游戏准确率
  double getAccuracy(GameState gameState) {
    final totalMoves = gameState.history.length;
    if (totalMoves == 0) return 1.0;
    final correctMoves = totalMoves - gameState.mistakes;
    return correctMoves / totalMoves;
  }

  /// 获取已填单元格数量
  int getFilledCellCount(Board board) => board.getFilledCells().length;

  /// 获取总移动次数
  // ignore: prefer_expression_function_bodies
  int getTotalMoves(GameState gameState) {
    return gameState.history.length - 1; // 减去初始状态
  }

  /// 获取总用时
  Duration getTotalTime(GameState gameState) {
    if (gameState.completionTime != null && gameState.startTime != null) {
      return gameState.completionTime!.difference(gameState.startTime!);
    }
    return Duration(seconds: gameState.elapsedTime);
  }

  /// 获取游戏完成百分比（字符串格式）
  String getCompletionPercentageString(GameState gameState) {
    final percentage = getCompletionPercentage(gameState);
    return '${(percentage * 100).toStringAsFixed(1)}%';
  }

  /// 获取游戏准确率（字符串格式）
  String getAccuracyString(GameState gameState) {
    final accuracy = getAccuracy(gameState);
    return '${(accuracy * 100).toStringAsFixed(1)}%';
  }
}
