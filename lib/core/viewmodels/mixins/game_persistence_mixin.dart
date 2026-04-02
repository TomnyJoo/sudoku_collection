import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/index.dart';

mixin GamePersistenceMixin on ChangeNotifier {
  GameState get gameState;
  set gameState(GameState value);
  GameService get gameService;
  
  Timer? saveDebounceTimer;
  
  Future<void> saveGameInternal() async {
    try {
      if (gameState.isCompleted) return;
      if (gameState.startTime == null) return;
      
      saveDebounceTimer?.cancel();
      
      if (_isValidGameState(gameState)) {
        await gameService.saveGameState(gameState);
      }
    } catch (e) {
      _handleError('保存游戏失败', e);
    }
  }
  
  void saveGameSyncInternal() {
    try {
      if (gameState.isCompleted) return;
      if (gameState.startTime == null) return;
      
      if (_isValidGameState(gameState)) {
        gameService.saveGameState(gameState);
      }
    } catch (e) {
      _handleError('保存游戏失败', e);
    }
  }
  
  Future<void> loadGameInternal() async {
    try {
      final saveKey = '${gameService.gameType}_current';
      final savedState = await gameService.loadGameState(saveKey);
      
      if (savedState != null &&
          !savedState.isCompleted &&
          savedState.startTime != null) {
        gameState = savedState;
        notifyListeners();
      }
    } on RangeError catch (e) {
      _handleError('加载游戏失败：历史记录索引超出范围', e);
      await gameService.deleteGameState('${gameService.gameType}_current');
    } catch (e) {
      _handleError('加载游戏失败', e);
    }
  }
  
  bool _isValidGameState(GameState state) {
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
  
  void _handleError(String message, dynamic error) {
    AppLogger.error(message, error, StackTrace.current);
  }
  
  void disposeSaveTimer() {
    saveDebounceTimer?.cancel();
  }
}
