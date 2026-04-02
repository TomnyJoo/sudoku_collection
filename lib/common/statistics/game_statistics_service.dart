import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/common/statistics/game_statistics.dart';

/// 游戏统计服务, 提供游戏统计的查询、加载和清除功能
class GameStatisticsService {
  // ========== 游戏统计键  ==========
  static const String _standardStatisticsKey = 'standard_game_statistics';
  static const String _jigsawStatisticsKey = 'jigsaw_game_statistics';
  static const String _diagonalStatisticsKey = 'diagonal_game_statistics';
  static const String _killerStatisticsKey = 'killer_game_statistics';
  static const String _windowStatisticsKey = 'window_game_statistics';
  static const String _samuraiStatisticsKey = 'samurai_game_statistics';
  static const int _maxRecentGames = 20;

  // ========== 游戏统计服务  ==========

  /// 保存游戏统计
  static Future<void> saveStatistics(
    final GameStatistics statistics,
    final String key,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(statistics.toJson());
      await prefs.setString(key, json);
    } catch (e) {
      rethrow;
    }
  }

  /// 加载标准数独游戏统计
  static Future<GameStatistics?> loadStandardStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_standardStatisticsKey);

      if (json == null) {
        return null;
      }

      final statistics = GameStatistics.fromJson(jsonDecode(json), 'standard');
      return statistics;
    } catch (e) {
      return null;
    }
  }

  /// 加载锯齿数独游戏统计
  static Future<GameStatistics?> loadJigsawStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_jigsawStatisticsKey);

      if (json == null) {
        return null;
      }

      final statistics = GameStatistics.fromJson(jsonDecode(json), 'jigsaw');
      return statistics;
    } catch (e) {
      return null;
    }
  }

  /// 加载对角线数独游戏统计
  static Future<GameStatistics?> loadDiagonalStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_diagonalStatisticsKey);

      if (json == null) {
        return null;
      }

      final statistics = GameStatistics.fromJson(jsonDecode(json), 'diagonal');
      return statistics;
    } catch (e) {
      return null;
    }
  }

  /// 加载杀手数独游戏统计
  static Future<GameStatistics?> loadKillerStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_killerStatisticsKey);

      if (json == null) {
        return null;
      }

      final statistics = GameStatistics.fromJson(jsonDecode(json), 'killer');
      return statistics;
    } catch (e) {
      return null;
    }
  }

  /// 加载窗口数独游戏统计
  static Future<GameStatistics?> loadWindowStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_windowStatisticsKey);

      if (json == null) {
        return null;
      }

      final statistics = GameStatistics.fromJson(jsonDecode(json), 'window');
      return statistics;
    } catch (e) {
      return null;
    }
  }

  /// 加载武士数独游戏统计
  static Future<GameStatistics?> loadSamuraiStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_samuraiStatisticsKey);

      if (json == null) {
        return null;
      }

      final statistics = GameStatistics.fromJson(jsonDecode(json), 'samurai');
      return statistics;
    } catch (e) {
      return null;
    }
  }

  /// 加载武士数独游戏统计
  static Future<GameStatistics> loadSamuraiStatisticsAsGameStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('samurai_game_statistics');

      if (json == null) {
        return GameStatistics.empty('samurai');
      }

      final results = jsonDecode(json) as List<dynamic>;

      final totalGames = results.length;
      final completedGames = results.where((r) => r['completed'] == true).length;
      final completionRate = GameStatistics.calculateCompletionRate(totalGames, completedGames);

      final completedResults = results.where((r) => r['completed'] == true).toList();
      final totalTime = completedResults.fold<int>(0, (sum, r) => sum + ((r['timeElapsed'] as int?) ?? 0));
      final averageTime = completedGames > 0 ? totalTime ~/ completedGames : 0;

      int bestTime = 0;
      for (final result in completedResults) {
        final time = (result['timeElapsed'] as int?) ?? 0;
        if (time > 0 && (bestTime == 0 || time < bestTime)) {
          bestTime = time;
        }
      }

      final totalMistakes = results.fold<int>(0, (sum, r) => sum + ((r['mistakes'] as int?) ?? 0));
      final averageMistakes = completedGames > 0 ? totalMistakes / completedGames : 0.0;

      final recentGames = results.take(_maxRecentGames).map((r) {
        final timestamp = DateTime.tryParse(r['timestamp'] as String? ?? '') ?? DateTime.now().toUtc();
        return GameRecord(
          id: timestamp.millisecondsSinceEpoch.toString(),
          gameType: 'samurai',
          difficulty: r['difficulty'] as String? ?? 'Medium',
          isCompleted: r['completed'] as bool? ?? false,
          time: (r['timeElapsed'] as int?) ?? 0,
          mistakes: (r['mistakes'] as int?) ?? 0,
          timestamp: timestamp,
        );
      }).toList();

      return GameStatistics(
        gameType: 'samurai',
        totalGames: totalGames,
        completedGames: completedGames,
        completionRate: completionRate,
        averageTime: averageTime,
        bestTime: bestTime,
        averageMistakes: averageMistakes,
        difficultyStats: {},
        recentGames: recentGames,
      );
    } catch (e) {
      return GameStatistics.empty('samurai');
    }
  }

  /// 加载所有游戏统计
  static Future<Map<String, GameStatistics>> getAllStatistics() async {
    final standardStats = await loadStandardStatistics();
    final jigsawStats = await loadJigsawStatistics();
    final diagonalStats = await loadDiagonalStatistics();
    final killerStats = await loadKillerStatistics();
    final windowStats = await loadWindowStatistics();
    final samuraiStats = await loadSamuraiStatistics();

    return {
      'standard': standardStats ?? GameStatistics.empty('standard'),
      'jigsaw': jigsawStats ?? GameStatistics.empty('jigsaw'),
      'diagonal': diagonalStats ?? GameStatistics.empty('diagonal'),
      'killer': killerStats ?? GameStatistics.empty('killer'),
      'window': windowStats ?? GameStatistics.empty('window'),
      'samurai': samuraiStats ?? GameStatistics.empty('samurai'),
    };
  }

  /// 加载所有游戏统计
  static Future<GameStatistics> getCombinedStatistics() async {
    final allStats = await getAllStatistics();
    final standard = allStats['standard']!;
    final jigsaw = allStats['jigsaw']!;
    final diagonal = allStats['diagonal']!;
    final killer = allStats['killer']!;
    final window = allStats['window']!;
    final samurai = allStats['samurai']!;

    final combinedRecentGames =
        [...standard.recentGames, ...jigsaw.recentGames, ...diagonal.recentGames, ...killer.recentGames, ...window.recentGames, ...samurai.recentGames].toList()
          ..sort((final a, final b) => b.timestamp.compareTo(a.timestamp))
          ..take(_maxRecentGames);

    final combinedDifficultyStats = <String, DifficultyStats>{}
    ..addAll(standard.difficultyStats);
    jigsaw.difficultyStats.forEach((final key, final value) {
      final existing = combinedDifficultyStats[key];
      if (existing != null) {
        combinedDifficultyStats[key] = DifficultyStats(
          difficulty: key,
          totalGames: existing.totalGames + value.totalGames,
          completedGames: existing.completedGames + value.completedGames,
          completionRate: GameStatistics.calculateCompletionRate(
            existing.totalGames + value.totalGames,
            existing.completedGames + value.completedGames,
          ),
          averageTime:
              (existing.averageTime * existing.completedGames +
                  value.averageTime * value.completedGames) ~/
              (existing.completedGames + value.completedGames),
          bestTime: existing.bestTime == 0
              ? value.bestTime
              : value.bestTime == 0
              ? existing.bestTime
              : existing.bestTime < value.bestTime
              ? existing.bestTime
              : value.bestTime,
          averageMistakes:
              (existing.averageMistakes * existing.completedGames +
                  value.averageMistakes * value.completedGames) /
              (existing.completedGames + value.completedGames),
        );
      } else {
        combinedDifficultyStats[key] = value;
      }
    });
    diagonal.difficultyStats.forEach((final key, final value) {
      final existing = combinedDifficultyStats[key];
      if (existing != null) {
        combinedDifficultyStats[key] = DifficultyStats(
          difficulty: key,
          totalGames: existing.totalGames + value.totalGames,
          completedGames: existing.completedGames + value.completedGames,
          completionRate: GameStatistics.calculateCompletionRate(
            existing.totalGames + value.totalGames,
            existing.completedGames + value.completedGames,
          ),
          averageTime:
              (existing.averageTime * existing.completedGames +
                  value.averageTime * value.completedGames) ~/
              (existing.completedGames + value.completedGames),
          bestTime: existing.bestTime == 0
              ? value.bestTime
              : value.bestTime == 0
              ? existing.bestTime
              : existing.bestTime < value.bestTime
              ? existing.bestTime
              : value.bestTime,
          averageMistakes:
              (existing.averageMistakes * existing.completedGames +
                  value.averageMistakes * value.completedGames) /
              (existing.completedGames + value.completedGames),
        );
      } else {
        combinedDifficultyStats[key] = value;
      }
    });
    killer.difficultyStats.forEach((final key, final value) {
      final existing = combinedDifficultyStats[key];
      if (existing != null) {
        combinedDifficultyStats[key] = DifficultyStats(
          difficulty: key,
          totalGames: existing.totalGames + value.totalGames,
          completedGames: existing.completedGames + value.completedGames,
          completionRate: GameStatistics.calculateCompletionRate(
            existing.totalGames + value.totalGames,
            existing.completedGames + value.completedGames,
          ),
          averageTime:
              (existing.averageTime * existing.completedGames +
                  value.averageTime * value.completedGames) ~/
              (existing.completedGames + value.completedGames),
          bestTime: existing.bestTime == 0
              ? value.bestTime
              : value.bestTime == 0
              ? existing.bestTime
              : existing.bestTime < value.bestTime
              ? existing.bestTime
              : value.bestTime,
          averageMistakes:
              (existing.averageMistakes * existing.completedGames +
                  value.averageMistakes * value.completedGames) /
              (existing.completedGames + value.completedGames),
        );
      } else {
        combinedDifficultyStats[key] = value;
      }
    });
    window.difficultyStats.forEach((final key, final value) {
      final existing = combinedDifficultyStats[key];
      if (existing != null) {
        combinedDifficultyStats[key] = DifficultyStats(
          difficulty: key,
          totalGames: existing.totalGames + value.totalGames,
          completedGames: existing.completedGames + value.completedGames,
          completionRate: GameStatistics.calculateCompletionRate(
            existing.totalGames + value.totalGames,
            existing.completedGames + value.completedGames,
          ),
          averageTime:
              (existing.averageTime * existing.completedGames +
                  value.averageTime * value.completedGames) ~/
              (existing.completedGames + value.completedGames),
          bestTime: existing.bestTime == 0
              ? value.bestTime
              : value.bestTime == 0
              ? existing.bestTime
              : existing.bestTime < value.bestTime
              ? existing.bestTime
              : value.bestTime,
          averageMistakes:
              (existing.averageMistakes * existing.completedGames +
                  value.averageMistakes * value.completedGames) /
              (existing.completedGames + value.completedGames),
        );
      } else {
        combinedDifficultyStats[key] = value;
      }
    });
    
    samurai.difficultyStats.forEach((final key, final value) {
      final existing = combinedDifficultyStats[key];
      if (existing != null) {
        combinedDifficultyStats[key] = DifficultyStats(
          difficulty: key,
          totalGames: existing.totalGames + value.totalGames,
          completedGames: existing.completedGames + value.completedGames,
          completionRate: GameStatistics.calculateCompletionRate(
            existing.totalGames + value.totalGames,
            existing.completedGames + value.completedGames,
          ),
          averageTime:
              (existing.averageTime * existing.completedGames +
                  value.averageTime * value.completedGames) ~/
              (existing.completedGames + value.completedGames),
          bestTime: existing.bestTime == 0
              ? value.bestTime
              : value.bestTime == 0
              ? existing.bestTime
              : existing.bestTime < value.bestTime
              ? existing.bestTime
              : value.bestTime,
          averageMistakes:
              (existing.averageMistakes * existing.completedGames +
                  value.averageMistakes * value.completedGames) /
              (existing.completedGames + value.completedGames),
        );
      } else {
        combinedDifficultyStats[key] = value;
      }
    });

    return GameStatistics(
      gameType: 'combined',
      totalGames: standard.totalGames + jigsaw.totalGames + diagonal.totalGames + killer.totalGames + window.totalGames + samurai.totalGames,
      completedGames: standard.completedGames + jigsaw.completedGames + diagonal.completedGames + killer.completedGames + window.completedGames + samurai.completedGames,
      completionRate: GameStatistics.calculateCompletionRate(
        standard.totalGames + jigsaw.totalGames + diagonal.totalGames + killer.totalGames + window.totalGames + samurai.totalGames,
        standard.completedGames + jigsaw.completedGames + diagonal.completedGames + killer.completedGames + window.completedGames + samurai.completedGames,
      ),
      averageTime:
          (standard.averageTime * standard.completedGames +
              jigsaw.averageTime * jigsaw.completedGames +
              diagonal.averageTime * diagonal.completedGames +
              killer.averageTime * killer.completedGames +
              window.averageTime * window.completedGames +
              samurai.averageTime * samurai.completedGames) ~/
          (standard.completedGames + jigsaw.completedGames + diagonal.completedGames + killer.completedGames + window.completedGames + samurai.completedGames),
      bestTime: _calculateBestTime([standard, jigsaw, diagonal, killer, window, samurai]),
      averageMistakes:
          (standard.averageMistakes * standard.completedGames +
              jigsaw.averageMistakes * jigsaw.completedGames +
              diagonal.averageMistakes * diagonal.completedGames +
              killer.averageMistakes * killer.completedGames +
              window.averageMistakes * window.completedGames +
              samurai.averageMistakes * samurai.completedGames) /
          (standard.completedGames + jigsaw.completedGames + diagonal.completedGames + killer.completedGames + window.completedGames + samurai.completedGames),
      difficultyStats: combinedDifficultyStats,
      recentGames: combinedRecentGames,
    );
  }

  /// 清除标准数独游戏统计
  static Future<void> clearStandardStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_standardStatisticsKey);
    } catch (e) {
      rethrow;
    }
  }

  /// 清除锯齿数独游戏统计
  static Future<void> clearJigsawStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jigsawStatisticsKey);
    } catch (e) {
      rethrow;
    }
  }

  /// 清除对角线数独游戏统计
  static Future<void> clearDiagonalStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_diagonalStatisticsKey);
    } catch (e) {
      rethrow;
    }
  }

  /// 清除杀手数独游戏统计
  static Future<void> clearKillerStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_killerStatisticsKey);
    } catch (e) {
      rethrow;
    }
  }

  /// 清除窗口数独游戏统计
  static Future<void> clearWindowStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_windowStatisticsKey);
    } catch (e) {
      rethrow;
    }
  }

  /// 清除武士数独游戏统计
  static Future<void> clearSamuraiStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_samuraiStatisticsKey);
    } catch (e) {
      rethrow;
    }
  }

  // 通用方法：添加游戏记录
  static Future<void> _addGameRecord({
    required final String gameType,
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
    required final String storageKey,
    required final Future<GameStatistics?> Function() loadStatistics,
  }) async {
    try {
      final statistics = await loadStatistics() ?? GameStatistics.empty(gameType);
      final record = GameRecord.create(
        gameType: gameType,
        difficulty: difficulty,
        isCompleted: isCompleted,
        time: time,
        mistakes: mistakes,
      );

      final newTotalGames = statistics.totalGames + 1;
      final newCompletedGames = statistics.completedGames + (isCompleted ? 1 : 0);
      final newCompletionRate = GameStatistics.calculateCompletionRate(
        newTotalGames,
        newCompletedGames,
      );

      final totalTime = statistics.averageTime * statistics.completedGames + (isCompleted ? time : 0);
      final newAverageTime = newCompletedGames > 0
          ? (totalTime / newCompletedGames).round()
          : 0;

      final newBestTime = statistics.bestTime == 0
          ? (isCompleted ? time : statistics.bestTime)
          : (isCompleted && time < statistics.bestTime ? time : statistics.bestTime);

      final totalMistakes = statistics.averageMistakes * statistics.completedGames + (isCompleted ? mistakes : 0);
      final newAverageMistakes = newCompletedGames > 0
          ? totalMistakes / newCompletedGames
          : 0.0;

      final difficultyStats = statistics.difficultyStats[difficulty] ?? DifficultyStats.empty(difficulty);
      final newDifficultyTotalGames = difficultyStats.totalGames + 1;
      final newDifficultyCompletedGames = difficultyStats.completedGames + (isCompleted ? 1 : 0);
      final newDifficultyCompletionRate = GameStatistics.calculateCompletionRate(
        newDifficultyTotalGames,
        newDifficultyCompletedGames,
      );

      final difficultyTotalTime = difficultyStats.averageTime * difficultyStats.completedGames + (isCompleted ? time : 0);
      final newDifficultyAverageTime = newDifficultyCompletedGames > 0
          ? (difficultyTotalTime / newDifficultyCompletedGames).round()
          : 0;

      final newDifficultyBestTime = difficultyStats.bestTime == 0
          ? (isCompleted ? time : difficultyStats.bestTime)
          : (isCompleted && time < difficultyStats.bestTime ? time : difficultyStats.bestTime);

      final difficultyTotalMistakes = difficultyStats.averageMistakes * difficultyStats.completedGames + (isCompleted ? mistakes : 0);
      final newDifficultyAverageMistakes = newDifficultyCompletedGames > 0
          ? difficultyTotalMistakes / newDifficultyCompletedGames
          : 0.0;

      final updatedDifficultyStats = DifficultyStats(
        difficulty: difficulty,
        totalGames: newDifficultyTotalGames,
        completedGames: newDifficultyCompletedGames,
        completionRate: newDifficultyCompletionRate,
        averageTime: newDifficultyAverageTime,
        bestTime: newDifficultyBestTime,
        averageMistakes: newDifficultyAverageMistakes,
      );

      final newRecentGames = [record, ...statistics.recentGames].take(_maxRecentGames).toList();

      // 计算连续完成天数
      final completedGames = newRecentGames.where((game) => game.isCompleted).toList();
      final (consecutiveDays, longestStreak) = calculateStreaks(completedGames);
      
      // 计算游戏时长分布
      final timeDistribution = calculateTimeDistribution(completedGames);
      
      // 分析错误模式
      final errorPatterns = analyzeErrorPatterns(newRecentGames);
      
      // 计算推荐难度
      final recommendedDifficulty = calculateRecommendedDifficulty(newRecentGames, difficulty);

      final newStatistics = GameStatistics(
        gameType: gameType,
        totalGames: newTotalGames,
        completedGames: newCompletedGames,
        completionRate: newCompletionRate,
        averageTime: newAverageTime,
        bestTime: newBestTime,
        averageMistakes: newAverageMistakes,
        difficultyStats: {
          ...statistics.difficultyStats,
          difficulty: updatedDifficultyStats,
        },
        recentGames: newRecentGames,
        consecutiveDays: consecutiveDays,
        longestStreak: longestStreak,
        timeDistribution: timeDistribution,
        errorPatterns: errorPatterns,
        recommendedDifficulty: recommendedDifficulty,
      );

      await saveStatistics(newStatistics, storageKey);
    } catch (e) {
      // 记录错误但不中断流程
      debugPrint('Error in statistics service: $e');
    }
  }

  /// 统一的游戏记录添加方法
  static Future<void> addGameRecord({
    required final String gameType,
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    final storageKey = _getStorageKey(gameType);
    final loadStatistics = _getLoadStatistics(gameType);
    
    await _addGameRecord(
      gameType: gameType,
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
      storageKey: storageKey,
      loadStatistics: loadStatistics,
    );
  }

  /// 获取存储键
  static String _getStorageKey(String gameType) {
    switch (gameType) {
      case 'standard':
        return _standardStatisticsKey;
      case 'jigsaw':
        return _jigsawStatisticsKey;
      case 'diagonal':
        return _diagonalStatisticsKey;
      case 'killer':
        return _killerStatisticsKey;
      case 'window':
        return _windowStatisticsKey;
      case 'samurai':
        return _samuraiStatisticsKey;
      default:
        throw ArgumentError('Unknown game type: $gameType');
    }
  }

  /// 获取加载统计方法
  static Future<GameStatistics?> Function() _getLoadStatistics(String gameType) {
    switch (gameType) {
      case 'standard':
        return loadStandardStatistics;
      case 'jigsaw':
        return loadJigsawStatistics;
      case 'diagonal':
        return loadDiagonalStatistics;
      case 'killer':
        return loadKillerStatistics;
      case 'window':
        return loadWindowStatistics;
      case 'samurai':
        return loadSamuraiStatistics;
      default:
        throw ArgumentError('Unknown game type: $gameType');
    }
  }

  /// 添加标准数独游戏记录
  static Future<void> addStandardGameRecord({
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    await addGameRecord(
      gameType: 'standard',
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
    );
  }

  /// 添加锯齿数独游戏记录
  static Future<void> addJigsawGameRecord({
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    await addGameRecord(
      gameType: 'jigsaw',
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
    );
  }

  /// 添加对角线数独游戏记录
  static Future<void> addDiagonalGameRecord({
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    await addGameRecord(
      gameType: 'diagonal',
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
    );
  }

  /// 添加杀手数独游戏记录
  static Future<void> addKillerGameRecord({
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    await addGameRecord(
      gameType: 'killer',
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
    );
  }

  /// 添加窗口数独游戏记录
  static Future<void> addWindowGameRecord({
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    await addGameRecord(
      gameType: 'window',
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
    );
  }

  /// 添加武士数独游戏记录
  static Future<void> addSamuraiGameRecord({
    required final String difficulty,
    required final bool isCompleted,
    required final int time,
    required final int mistakes,
  }) async {
    await addGameRecord(
      gameType: 'samurai',
      difficulty: difficulty,
      isCompleted: isCompleted,
      time: time,
      mistakes: mistakes,
    );
  }

  /// 清除指定游戏的统计
  static Future<void> clearStatistics(String gameType) async {
    final storageKey = _getStorageKey(gameType);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (_) {
      rethrow;
    }
  }

  /// 清除所有游戏的统计
  static Future<void> clearAllStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_standardStatisticsKey);
      await prefs.remove(_jigsawStatisticsKey);
      await prefs.remove(_diagonalStatisticsKey);
      await prefs.remove(_killerStatisticsKey);
      await prefs.remove(_windowStatisticsKey);
      await prefs.remove(_samuraiStatisticsKey);
    } catch (_) {
      rethrow;
    }
  }

  /// 导出所有游戏的统计
  static Future<String> exportAllStatistics() async {
    try {
      final allStats = await getAllStatistics();
      final json = jsonEncode({
        'standard': allStats['standard']?.toJson(),
        'jigsaw': allStats['jigsaw']?.toJson(),
        'diagonal': allStats['diagonal']?.toJson(),
        'killer': allStats['killer']?.toJson(),
        'window': allStats['window']?.toJson(),
        'samurai': allStats['samurai']?.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      });
      return json;
    } catch (e) {
      rethrow;
    }
  }

  /// 导出标准数独游戏统计
  static Future<String> exportStandardStatistics() async {
    final stats = await loadStandardStatistics();
    return jsonEncode(stats?.toJson() ?? {});
  }

  /// 导出锯齿数独游戏统计
  static Future<String> exportJigsawStatistics() async {
    final stats = await loadJigsawStatistics();
    return jsonEncode(stats?.toJson() ?? {});
  }

  /// 导入标准数独游戏统计
  static Future<void> importStandardStatistics(final String json) async {
    try {
      final data = jsonDecode(json);
      final stats = GameStatistics.fromJson(data, 'standard');
      await saveStandardStatistics(stats);
    } catch (e) {
      rethrow;
    }
  }

  /// 导入锯齿数独游戏统计
  static Future<void> importJigsawStatistics(final String json) async {
    try {
      final data = jsonDecode(json);
      final stats = GameStatistics.fromJson(data, 'jigsaw');
      await saveJigsawStatistics(stats);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取最近的游戏记录
  static Future<List<GameRecord>> getRecentGames({final int limit = 20}) async {
    final allStats = await getAllStatistics();
    final allRecords = <GameRecord>[
      ...allStats['standard']!.recentGames,
      ...allStats['jigsaw']!.recentGames,
      ...allStats['diagonal']!.recentGames,
      ...allStats['killer']!.recentGames,
      ...allStats['window']!.recentGames,
      ...allStats['samurai']!.recentGames,
    ]

    ..sort((final a, final b) => b.timestamp.compareTo(a.timestamp));
    return allRecords.take(limit).toList();
  }

  /// 保存标准数独游戏统计
  static Future<void> saveStandardStatistics(
    final GameStatistics statistics,
  ) async {
    await saveStatistics(statistics, _standardStatisticsKey);
  }

  /// 保存锯齿数独游戏统计
  static Future<void> saveJigsawStatistics(
    final GameStatistics statistics,
  ) async {
    await saveStatistics(statistics, _jigsawStatisticsKey);
  }

  /// 保存对角线数独游戏统计
  static Future<void> saveDiagonalStatistics(
    final GameStatistics statistics,
  ) async {
    await saveStatistics(statistics, _diagonalStatisticsKey);
  }

  /// 保存杀手数独游戏统计
  static Future<void> saveKillerStatistics(
    final GameStatistics statistics,
  ) async {
    await saveStatistics(statistics, _killerStatisticsKey);
  }

  /// 保存窗口数独游戏统计
  static Future<void> saveWindowStatistics(
    final GameStatistics statistics,
  ) async {
    await saveStatistics(statistics, _windowStatisticsKey);
  }

  /// 保存武士数独游戏统计
  static Future<void> saveSamuraiStatistics(
    final GameStatistics statistics,
  ) async {
    await saveStatistics(statistics, _samuraiStatisticsKey);
  }

  /// 计算最佳时间
  static int _calculateBestTime(final List<GameStatistics> statsList) {
    int bestTime = 0;
    for (final stats in statsList) {
      if (stats.bestTime > 0) {
        if (bestTime == 0 || stats.bestTime < bestTime) {
          bestTime = stats.bestTime;
        }
      }
    }
    return bestTime;
  }

  /// 计算连续完成天数
  static (int, int) calculateStreaks(final List<GameRecord> completedGames) {
    if (completedGames.isEmpty) {
      return (0, 0);
    }

    // 提取所有完成日期并去重，按日期排序
    final completedDates = completedGames
        .where((record) => record.completedDate != null)
        .map((record) => DateTime(
              record.completedDate!.year,
              record.completedDate!.month,
              record.completedDate!.day,
            ))
        .toSet()
        .toList()

    ..sort((a, b) => b.compareTo(a));

    if (completedDates.isEmpty) {
      return (0, 0);
    }

    int consecutiveDays = 0;
    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? previousDate;

    for (final date in completedDates) {
      if (previousDate == null) {
        // 第一个日期
        currentStreak = 1;
        consecutiveDays = 1;
      } else {
        final difference = previousDate.difference(date).inDays;
        if (difference == 1) {
          // 连续的一天
          currentStreak++;
        } else if (difference > 1) {
          // 连续中断
          currentStreak = 1;
        }
      }

      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      previousDate = date;
    }

    // 检查最近的连续天数是否延续到今天
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final mostRecentDate = completedDates.first;
    final daysSinceLastCompletion = todayOnly.difference(mostRecentDate).inDays;

    if (daysSinceLastCompletion > 1) {
      // 如果最后一次完成不是今天或昨天，连续天数为0
      consecutiveDays = 0;
    }

    return (consecutiveDays, longestStreak);
  }

  /// 计算游戏时长分布
  static Map<String, int> calculateTimeDistribution(final List<GameRecord> completedGames) {
    final distribution = {
      '0-5分钟': 0,
      '5-10分钟': 0,
      '10-15分钟': 0,
      '15-20分钟': 0,
      '20-30分钟': 0,
      '30分钟以上': 0,
    };

    for (final game in completedGames) {
      if (game.isCompleted) {
        final minutes = game.time ~/ 60;
        if (minutes < 5) {
          distribution['0-5分钟'] = (distribution['0-5分钟'] ?? 0) + 1;
        } else if (minutes < 10) {
          distribution['5-10分钟'] = (distribution['5-10分钟'] ?? 0) + 1;
        } else if (minutes < 15) {
          distribution['10-15分钟'] = (distribution['10-15分钟'] ?? 0) + 1;
        } else if (minutes < 20) {
          distribution['15-20分钟'] = (distribution['15-20分钟'] ?? 0) + 1;
        } else if (minutes < 30) {
          distribution['20-30分钟'] = (distribution['20-30分钟'] ?? 0) + 1;
        } else {
          distribution['30分钟以上'] = (distribution['30分钟以上'] ?? 0) + 1;
        }
      }
    }

    return distribution;
  }

  /// 分析错误模式
  static Map<int, int> analyzeErrorPatterns(final List<GameRecord> games) {
    final errorPatterns = <int, int>{};

    for (final game in games) {
      if (game.errorDetails.isNotEmpty) {
        game.errorDetails.forEach((number, count) {
          errorPatterns[number] = (errorPatterns[number] ?? 0) + count;
        });
      }
    }

    return errorPatterns;
  }

  /// 计算推荐难度
  static String calculateRecommendedDifficulty(final List<GameRecord> recentGames, final String currentDifficulty) {
    // 至少需要3个已完成的游戏来计算推荐难度
    final completedGames = recentGames.where((game) => game.isCompleted).toList();
    if (completedGames.length < 3) {
      return currentDifficulty;
    }

    // 取最近3个已完成的游戏
    final recentCompletedGames = completedGames.take(3).toList();
    
    // 计算平均完成率和平均错误数
    final completionPercentages = recentCompletedGames.map((game) => game.completionPercentage).toList();
    final averageCompletionRate = completionPercentages.isNotEmpty 
        ? completionPercentages.reduce((a, b) => a + b) / completionPercentages.length 
        : 0.0;
    
    final mistakeCounts = recentCompletedGames.map((game) => game.mistakes).toList();
    final averageMistakes = mistakeCounts.isNotEmpty 
        ? mistakeCounts.reduce((a, b) => a + b) / mistakeCounts.length 
        : 0.0;
    
    // 难度级别顺序
    const difficultyLevels = ['easy', 'medium', 'hard', 'expert'];
    final currentIndex = difficultyLevels.indexOf(currentDifficulty);
    if (currentIndex == -1) return currentDifficulty;

    // 根据表现调整难度
    if (averageCompletionRate >= 95 && averageMistakes <= 2) {
      // 表现良好，尝试提高难度
      return currentIndex < difficultyLevels.length - 1 ? difficultyLevels[currentIndex + 1] : currentDifficulty;
    } else if (averageCompletionRate < 70 || averageMistakes > 5) {
      // 表现不佳，降低难度
      return currentIndex > 0 ? difficultyLevels[currentIndex - 1] : currentDifficulty;
    } else {
      // 表现稳定，保持当前难度
      return currentDifficulty;
    }
  }

  /// 记录未完成游戏
  static Future<void> recordIncompleteGame({
    required final String gameType,
    required final String difficulty,
    required final int time,
    required final int mistakes,
    required final double completionPercentage,
  }) async {
    try {
      GameStatistics? statistics;
      String key;
      Future<GameStatistics?> Function() loadStatistics;

      switch (gameType) {
        case 'standard':
          loadStatistics = loadStandardStatistics;
          key = _standardStatisticsKey;
          break;
        case 'jigsaw':
          loadStatistics = loadJigsawStatistics;
          key = _jigsawStatisticsKey;
          break;
        case 'diagonal':
          loadStatistics = loadDiagonalStatistics;
          key = _diagonalStatisticsKey;
          break;
        case 'killer':
          loadStatistics = loadKillerStatistics;
          key = _killerStatisticsKey;
          break;
        case 'window':
          loadStatistics = loadWindowStatistics;
          key = _windowStatisticsKey;
          break;
        case 'samurai':
          loadStatistics = loadSamuraiStatistics;
          key = _samuraiStatisticsKey;
          break;
        default:
          return;
      }

      // 加载统计数据
      statistics = await loadStatistics() ?? GameStatistics.empty(gameType);
      
      // 创建未完成游戏记录
      final record = GameRecord.create(
        gameType: gameType,
        difficulty: difficulty,
        isCompleted: false,
        time: time,
        mistakes: mistakes,
        completionPercentage: completionPercentage,
      );

      final newTotalGames = statistics.totalGames + 1;
      final newCompletedGames = statistics.completedGames;
      final newCompletionRate = GameStatistics.calculateCompletionRate(
        newTotalGames,
        newCompletedGames,
      );

      final totalTime = statistics.averageTime * statistics.completedGames;
      final newAverageTime = newCompletedGames > 0
          ? (totalTime / newCompletedGames).round()
          : 0;

      final newBestTime = statistics.bestTime;

      final totalMistakes = statistics.averageMistakes * statistics.completedGames;
      final newAverageMistakes = newCompletedGames > 0
          ? totalMistakes / newCompletedGames
          : 0.0;

      final difficultyStats = statistics.difficultyStats[difficulty] ??
          DifficultyStats.empty(difficulty);
      final newDifficultyTotalGames = difficultyStats.totalGames + 1;
      final newDifficultyCompletedGames = difficultyStats.completedGames;
      final newDifficultyCompletionRate = GameStatistics.calculateCompletionRate(
        newDifficultyTotalGames,
        newDifficultyCompletedGames,
      );

      final difficultyTotalTime = difficultyStats.averageTime * difficultyStats.completedGames;
      final newDifficultyAverageTime = newDifficultyCompletedGames > 0
          ? (difficultyTotalTime / newDifficultyCompletedGames).round()
          : 0;

      final newDifficultyBestTime = difficultyStats.bestTime;

      final difficultyTotalMistakes = difficultyStats.averageMistakes * difficultyStats.completedGames;
      final newDifficultyAverageMistakes = newDifficultyCompletedGames > 0
          ? difficultyTotalMistakes / newDifficultyCompletedGames
          : 0.0;

      final updatedDifficultyStats = DifficultyStats(
        difficulty: difficulty,
        totalGames: newDifficultyTotalGames,
        completedGames: newDifficultyCompletedGames,
        completionRate: newDifficultyCompletionRate,
        averageTime: newDifficultyAverageTime,
        bestTime: newDifficultyBestTime,
        averageMistakes: newDifficultyAverageMistakes,
      );

      final newRecentGames = [
        record,
        ...statistics.recentGames,
      ].take(_maxRecentGames).toList();

      // 计算连续完成天数
      final completedGames = newRecentGames.where((game) => game.isCompleted).toList();
      final (consecutiveDays, longestStreak) = calculateStreaks(completedGames);
      
      // 计算游戏时长分布
      final timeDistribution = calculateTimeDistribution(completedGames);
      
      // 分析错误模式
      final errorPatterns = analyzeErrorPatterns(newRecentGames);
      
      // 计算推荐难度
      final recommendedDifficulty = calculateRecommendedDifficulty(newRecentGames, difficulty);

      final newStatistics = GameStatistics(
        gameType: gameType,
        totalGames: newTotalGames,
        completedGames: newCompletedGames,
        completionRate: newCompletionRate,
        averageTime: newAverageTime,
        bestTime: newBestTime,
        averageMistakes: newAverageMistakes,
        difficultyStats: {
          ...statistics.difficultyStats,
          difficulty: updatedDifficultyStats,
        },
        recentGames: newRecentGames,
        consecutiveDays: consecutiveDays,
        longestStreak: longestStreak,
        timeDistribution: timeDistribution,
        errorPatterns: errorPatterns,
        recommendedDifficulty: recommendedDifficulty,
      );

      await saveStatistics(newStatistics, key);
    } catch (e) {
      // 记录错误但不中断流程
      debugPrint('Error in statistics service: $e');
    }
  }
} 
