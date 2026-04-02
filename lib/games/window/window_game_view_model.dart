import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/window/models/index.dart';
import 'package:sudoku/games/window/window_game_service.dart';

class WindowGameViewModel extends GameViewModel<WindowGameState> {
  WindowGameViewModel([AppSettings? settings])
      : super(
          _createInitialState(),
          WindowGameService(),
          settings,
        );

  WindowGameService get _windowGameService => gameService as WindowGameService;

  static WindowGameState _createInitialState() => WindowGameState(
      board: WindowBoard.empty(),
      initialBoard: WindowBoard.empty(),
      solution: WindowBoard.empty(),
      difficulty: Difficulty.medium.name,
    );

  @override
  WindowGameState get state => gameState as WindowGameState;

  @override
  @protected
  Future<void> generateNewGame(final Difficulty difficulty) async {
    if (isCancelled) return;

    final newState = await _windowGameService.generateGame(
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
