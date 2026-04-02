import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/models/index.dart';
import 'package:sudoku/games/standard/standard_game_service.dart';

class StandardGameViewModel extends GameViewModel<StandardGameState> {
  StandardGameViewModel([AppSettings? settings])
      : super(
          _createInitialState(),
          StandardGameService(),
          settings,
        );

  StandardGameService get _standardGameService => gameService as StandardGameService;

  static StandardGameState _createInitialState() => StandardGameState(
      board: StandardBoard.empty(),
      initialBoard: StandardBoard.empty(),
      solution: StandardBoard.empty(),
      difficulty: Difficulty.medium.name,
    );

  @override
  StandardGameState get state => gameState as StandardGameState;

  @override
  @protected
  Future<void> generateNewGame(final Difficulty difficulty) async {
    if (isCancelled) return;

    final newState = await _standardGameService.generateGame(
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

  Future<void> startCustomGame(StandardBoard initialBoard, {StandardBoard? solution}) async {
    final actualSolution = solution ?? initialBoard;
    final newState = StandardGameState(
      board: StandardBoard(
        size: initialBoard.size,
        cells: initialBoard.cells.map((row) => row.map((cell) => cell.copyWith()).toList()).toList(),
      ),
      initialBoard: initialBoard,
      solution: actualSolution,
      difficulty: 'custom',
      startTime: DateTime.now(),
    );
    gameState = newState;
    notifyListeners();
  }
}
