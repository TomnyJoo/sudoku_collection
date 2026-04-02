import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/index.dart';

/// 游戏仓库抽象类
/// 
/// 定义游戏状态持久化的抽象接口，并提供SharedPreferences的默认实现
/// 子类只需实现特定的序列化/反序列化逻辑
abstract class GameRepository<T extends GameState> {
  /// 保存游戏状态
  Future<void> saveGameState(final T state, final String saveKey) async {
    await ErrorHandler().handleAsync(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final stateJson = jsonEncode(state.toJson());
        await prefs.setString(saveKey, stateJson);
      },
      operationName: '保存游戏状态',
    );
  }

  /// 加载游戏状态
  Future<T?> loadGameState(final String saveKey) async => ErrorHandler().handleAsync(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final stateJson = prefs.getString(saveKey);
        if (stateJson == null) {
          return null;
        }

        final stateData = jsonDecode(stateJson);
        return fromJson(stateData);
      },
      operationName: '加载游戏状态',
    );

  /// 清除游戏状态
  Future<void> clearGameState(final String saveKey) async {
    await ErrorHandler().handleAsync(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(saveKey);
      },
      operationName: '清理保存数据',
    );
  }

  /// 获取所有保存的游戏
  Future<List<Map<String, dynamic>>> getAllSavedGames() async => ErrorHandler().handleAsync(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        final games = <Map<String, dynamic>>[];

        for (final key in keys) {
          if (key.contains('_current') || key.contains('_saved_')) {
            final stateJson = prefs.getString(key);
            if (stateJson != null) {
              final stateData = jsonDecode(stateJson);
              games.add({
                'key': key,
                'data': stateData,
              });
            }
          }
        }

        return games;
      },
      operationName: '获取所有保存的游戏',
    );

  /// 检查是否有保存的游戏
  Future<bool> hasSavedGame(final String saveKey) async => ErrorHandler().handleAsync(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey(saveKey);
      },
      operationName: '检查是否有保存的游戏',
    );

  /// 从JSON数据创建游戏状态
  /// 
  /// 子类必须实现此方法以处理特定游戏状态的反序列化
  T fromJson(Map<String, dynamic> json);
}
