import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/jigsaw/jigsaw_game_service.dart';
import 'package:sudoku/games/jigsaw/models/index.dart';

class JigsawGameViewModel extends GameViewModel<JigsawGameState> {
  JigsawGameViewModel([AppSettings? settings])
      : super(
          _createInitialState(),
          JigsawGameService(),
          settings,
        );

  JigsawGameService get _jigsawGameService => gameService as JigsawGameService;

  static JigsawGameState _createInitialState() {
    final emptyRegionMatrix = List.generate(9, (_) => List.filled(9, 0));
    return JigsawGameState(
      board: JigsawBoard.empty(regionMatrix: emptyRegionMatrix),
      initialBoard: JigsawBoard.empty(regionMatrix: emptyRegionMatrix),
      solution: JigsawBoard.empty(regionMatrix: emptyRegionMatrix),
      difficulty: Difficulty.medium.name,
    );
  }

  @override
  JigsawGameState get state => gameState as JigsawGameState;

  @override
  @protected
  Future<void> generateNewGame(final Difficulty difficulty) async {
    if (isCancelled) return;

    final newState = await _jigsawGameService.generateGame(
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
