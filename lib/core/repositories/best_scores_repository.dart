import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/index.dart';

/// 最佳成绩仓库抽象类
///
/// 定义最佳成绩持久化的抽象接口，并提供SharedPreferences的默认实现
abstract class BestScoresRepository {
  BestScoresRepository(this._bestScoresKey);
  final String _bestScoresKey;

  /// 保存最佳成绩
  ///
  /// 返回是否创造了新纪录
  Future<bool> saveBestScore(
    final String difficulty,
    final BestScore score,
  ) async => ErrorHandler().handleAsync(
    () async {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getString(_bestScoresKey) ?? '{}';
      final scores = Map<String, dynamic>.from(jsonDecode(scoresJson));

      final existingScore = scores[difficulty];
      var isNewBest = false;

      if (existingScore == null) {
        isNewBest = true;
      } else {
        final bestTime = existingScore['time'] as int;
        final bestMistakes = existingScore['mistakes'] as int;

        if (score.time < bestTime ||
            (score.time == bestTime && score.mistakes < bestMistakes)) {
          isNewBest = true;
        }
      }

      if (isNewBest) {
        scores[difficulty] = score.toJson();
        await prefs.setString(_bestScoresKey, jsonEncode(scores));
      }

      return isNewBest;
    },
    operationName: '保存最佳成绩',
    defaultValue: false,
  );

  /// 获取所有最佳成绩
  Future<Map<String, BestScore>> getAllBestScores() async =>
      ErrorHandler().handleAsync(
        () async {
          final prefs = await SharedPreferences.getInstance();
          final scoresJson = prefs.getString(_bestScoresKey) ?? '{}';
          final scores = Map<String, dynamic>.from(jsonDecode(scoresJson));

          return scores.map(
            (final key, final value) => MapEntry(
              key,
              BestScore.fromJson(value as Map<String, dynamic>),
            ),
          );
        },
        operationName: '获取最佳成绩',
        defaultValue: {},
      );

  /// 获取特定难度的最佳成绩
  Future<BestScore?> getBestScore(final String difficulty) async =>
      ErrorHandler().handleAsync(
        () async {
          final prefs = await SharedPreferences.getInstance();
          final scoresJson = prefs.getString(_bestScoresKey) ?? '{}';
          final scores = Map<String, dynamic>.from(jsonDecode(scoresJson));

          final scoreData = scores[difficulty];
          if (scoreData == null) {
            return null;
          }

          return BestScore.fromJson(scoreData as Map<String, dynamic>);
        },
        operationName: '获取最佳成绩',
      );

  /// 清除所有最佳成绩
  Future<void> clearBestScores() async => ErrorHandler().handleAsync(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bestScoresKey);
  }, operationName: '清除最佳记录');

  /// 清除特定难度的最佳成绩
  Future<void> clearBestScore(final String difficulty) async =>
      ErrorHandler().handleAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        final scoresJson = prefs.getString(_bestScoresKey) ?? '{}';
        final scores = Map<String, dynamic>.from(jsonDecode(scoresJson))

        ..remove(difficulty);
        await prefs.setString(_bestScoresKey, jsonEncode(scores));
      }, operationName: '清除最佳记录');
}
