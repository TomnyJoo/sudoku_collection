import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 保存的游戏信息
class SavedGameInfo {

  SavedGameInfo({
    required this.gameType,
    required this.saveKey,
    required this.timestamp,
    required this.difficulty,
  });

  factory SavedGameInfo.fromJson(Map<String, dynamic> json) => SavedGameInfo(
    gameType: json['gameType'] as String,
    saveKey: json['saveKey'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    difficulty: json['difficulty'] as String,
  );

  final String gameType;
  final String saveKey;
  final DateTime timestamp;
  final String difficulty;

  Map<String, dynamic> toJson() => {
    'gameType': gameType,
    'saveKey': saveKey,
    'timestamp': timestamp.toIso8601String(),
    'difficulty': difficulty,
  };
}

/// 游戏保存管理器, 统一管理所有游戏的保存状态，提供保存游戏的查询、加载和清除功能
class GameSaveManager {
  /// 获取所有保存的游戏
  static Future<List<SavedGameInfo>> getAllSavedGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final savedGames = <SavedGameInfo>[];

      for (final key in keys) {
        if (key.endsWith('_current')) {
          final gameType = key.replaceAll('_current', '');
          final stateJson = prefs.getString(key);
          if (stateJson != null) {
            try {
              final stateData = jsonDecode(stateJson);
              // 检查游戏状态完整性
              if (_isValidGameState(stateData)) {
                savedGames.add(
                  SavedGameInfo(
                    gameType: gameType,
                    saveKey: key,
                    timestamp: stateData['startTime'] != null
                        ? DateTime.parse(stateData['startTime'] as String)
                        : DateTime.now(),
                    difficulty: stateData['difficulty'] ?? 'unknown',
                  ),
                );
              }
            } catch (e) {
              // 解析失败，跳过该保存
            }
          }
        }
      }

      // 按时间排序，最新的在前
      savedGames.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return savedGames;
    } catch (e) {
      return [];
    }
  }

  /// 检查游戏状态是否有效
  static bool _isValidGameState(Map<String, dynamic> stateData) {
    // 检查必要字段
    if (stateData['startTime'] == null) return false;
    if (stateData['isCompleted'] == true) return false;

    // 检查游戏数据
    if (stateData['board'] == null) return false;
    final boardData = stateData['board'] as Map<String, dynamic>;
    if (boardData['cells'] == null) return false;

    // 对于不同游戏类型的特定检查
    if (boardData['cells'] is List) {
      final cells = boardData['cells'] as List;
      if (cells.isEmpty) return false;
    }

    return true;
  }

  /// 检查是否有保存的游戏
  static Future<bool> hasSavedGames() async {
    final games = await getAllSavedGames();
    return games.isNotEmpty;
  }

  /// 清除指定游戏的保存
  static Future<void> clearSavedGame(String saveKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(saveKey);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 清除所有保存的游戏
  static Future<void> clearAllSavedGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.endsWith('_current')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }
}
