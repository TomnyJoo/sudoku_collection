import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

mixin GameLifecycleMixin on ChangeNotifier {
  GameState get gameState;
  set gameState(GameState value);
  
  GameTimer get gameTimer;
  GameService get gameService;
  
  bool get isCancelled;
  set isCancelled(bool value);
  
  bool get isLoading;
  set isLoading(bool value);
  
  GenerationStage get generationStage;
  set generationStage(GenerationStage value);
  
  AppSettings? get settings;
  
  bool get isPlaying => gameState.startTime != null && !gameState.isCompleted;
  bool get isPaused => gameState.startTime != null && !gameState.isCompleted && gameTimer.isPaused;
  
  void updateGenerationStage(GenerationStage stage) {
    generationStage = stage;
    notifyListeners();
  }
  
  Future<void> startNewGameInternal(
    Difficulty difficulty, {
    required Future<void> Function(Difficulty) generateNewGame,
    required Future<void> Function() resetGameState,
  }) async {
    isCancelled = false;
    isLoading = true;
    generationStage = GenerationStage.generatingSolution;
    notifyListeners();
    
    try {
      await resetGameState();
      gameTimer.reset();
      gameState = gameState.copyWith(
        mistakes: 0,
        elapsedTime: 0,
        isCompleted: false,
        difficulty: difficulty.name,
      );
      notifyListeners();
      await generateNewGame(difficulty);
      gameState = gameState.copyWith(startTime: DateTime.now());
      gameTimer.start();
      
      // 确保在主线程中播放音效
      if (PlatformDispatcher.instance.implicitView != null) {
        final audioManager = AudioManager();
        await audioManager.playStartSound();
      }
    } catch (e) {
      await resetGameState();
      gameTimer.reset();
      gameState = gameState.copyWith(
        mistakes: 0,
        elapsedTime: 0,
        isCompleted: false,
      );
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> pauseGameInternal({bool notify = true}) async {
    if (isPlaying) {
      gameTimer.pause();
      if (notify) {
        notifyListeners();
      }
    }
  }
  
  Future<void> resumeGameInternal() async {
    if (isPaused) {
      gameTimer.resume();
      notifyListeners();
    }
  }
  
  void cancelGameGenerationInternal() {
    isCancelled = true;
  }
  
  bool isValidGameState(GameState state) {
    if (state.startTime == null) return false;
    if (state.isCompleted) return false;
    if (state.board.cells.isEmpty) return false;
    
    int fixedCount = 0;
    for (final row in state.initialBoard.cells) {
      for (final cell in row) {
        if (cell.isFixed && cell.value != null) {
          fixedCount++;
        }
      }
    }
    
    bool hasFixedCellsInSolution = false;
    for (final row in state.solution.cells) {
      for (final cell in row) {
        if (cell.isFixed && cell.value != null) {
          hasFixedCellsInSolution = true;
          break;
        }
      }
      if (hasFixedCellsInSolution) break;
    }
    
    if (hasFixedCellsInSolution && fixedCount == 0) return false;
    
    int solutionCount = 0;
    for (final row in state.solution.cells) {
      for (final cell in row) {
        if (cell.value != null) {
          solutionCount++;
        }
      }
    }
    
    final totalCells = state.solution.size * state.solution.size;
    if (solutionCount < totalCells) return false;
    
    return true;
  }
}
