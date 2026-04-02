import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/diagonal_game_service.dart';
import 'package:sudoku/games/diagonal/models/index.dart';

class DiagonalGameViewModel extends GameViewModel<DiagonalGameState> {
  DiagonalGameViewModel([AppSettings? settings])
      : super(
          _createInitialState(),
          DiagonalGameService(),
          settings,
        );

  DiagonalGameService get _diagonalGameService => gameService as DiagonalGameService;

  static DiagonalGameState _createInitialState() => DiagonalGameState(
      board: DiagonalBoard.empty(),
      initialBoard: DiagonalBoard.empty(),
      solution: DiagonalBoard.empty(),
      difficulty: Difficulty.medium.name,
    );

  @override
  DiagonalGameState get state => gameState as DiagonalGameState;

  @override
  @protected
  Future<void> generateNewGame(final Difficulty difficulty) async {
    if (isCancelled) return;

    final newState = await _diagonalGameService.generateGame(
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

  Future<void> startCustomGame(DiagonalBoard initialBoard) async {
    final solution = initialBoard;
    final newState = DiagonalGameState(
      board: DiagonalBoard(
        size: initialBoard.size,
        cells: initialBoard.cells.map((row) => row.map((cell) => cell.copyWith()).toList()).toList(),
      ),
      initialBoard: initialBoard,
      solution: solution,
      difficulty: 'custom',
      startTime: DateTime.now(),
    );
    gameState = newState;
    notifyListeners();
  }
}
