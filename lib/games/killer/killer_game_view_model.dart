import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/killer/killer_game_service.dart';
import 'package:sudoku/games/killer/models/index.dart';

/// 杀手数独视图模型
///
/// 管理杀手数独游戏的状态和逻辑，包括：
/// - 游戏生成和重置
/// - 单元格值设置
/// - 候选数管理
/// - 提示功能
class KillerGameViewModel extends GameViewModel<KillerGameState> {
  KillerGameViewModel([AppSettings? settings])
      : super(
          _createInitialState(),
          KillerGameService(),
          settings,
        );

  KillerGameService get _killerGameService => gameService as KillerGameService;

  static KillerGameState _createInitialState() => KillerGameState(
      board: KillerBoard.empty(),
      initialBoard: KillerBoard.empty(),
      solution: KillerBoard.empty(),
      difficulty: Difficulty.medium.name,
    );

  @override
  KillerGameState get state => gameState as KillerGameState;

  @override
  @protected
  Future<void> generateNewGame(final Difficulty difficulty) async {
    if (isCancelled) return;

    final newState = await _killerGameService.generateGame(
      difficulty: difficulty,
      onStageUpdate: updateGenerationStage,
    );
    
    gameState = newState;
    notifyListeners();
  }

  @override
  @protected
  Future<void> resetGameState() async {
    gameState = _createInitialState();
    notifyListeners();
  }
}
