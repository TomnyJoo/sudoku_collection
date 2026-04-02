import 'package:flutter/foundation.dart';
import 'package:sudoku/core/index.dart';

mixin GameStateMixin on ChangeNotifier {
  GameState get gameState;
  set gameState(GameState value);
  
  GameTimer get gameTimer;
  
  void updateGameState(GameState newState) {
    gameState = newState;
    notifyListeners();
  }
  
  bool get isPlaying => gameState.startTime != null && !gameState.isCompleted;
  bool get isPaused => gameState.startTime != null && !gameState.isCompleted && gameTimer.isPaused;
  bool get isCompleted => gameState.isCompleted;
  Duration get elapsedTime => Duration(seconds: gameState.elapsedTime);
  bool get isMarkMode => gameState.isMarkMode;
  bool get isAutoMarkMode => gameState.isAutoMarkMode;
  bool get showSolution => gameState.isShowingSolution;
  double get completionPercentage => gameState.completionPercentage;
  int get errorCount => gameState.mistakes;
  
  Future<void> toggleMarkMode() async {
    updateGameState(gameState.toggleMarkMode());
  }
  
  Future<void> toggleAutoMarkMode() async {
    updateGameState(gameState.toggleAutoMarkMode());
  }
  
  Future<void> toggleShowSolution() async {
    updateGameState(gameState.isShowingSolution 
        ? gameState.hideSolution() 
        : gameState.showSolution());
  }
  
  Future<void> resetGame() async {
    updateGameState(gameState.resetGame());
  }
}
