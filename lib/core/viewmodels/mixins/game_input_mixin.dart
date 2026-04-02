import 'package:flutter/foundation.dart';
import 'package:sudoku/core/index.dart';

mixin GameInputMixin on ChangeNotifier {
  GameState get gameState;
  set gameState(GameState value);
  
  GameService get gameService;
  
  bool get isPlaying;
  
  Future<void> handleCellSelectionInternal(int row, int col) async {
    final newBoard = gameState.board.selectCell(row, col);
    gameState = gameState.updateBoard(newBoard);
  }
  
  Future<void> setCellValueInternal(
    int row,
    int col,
    int? value,
  ) async {
    final newState = gameService.setCellValue(
      gameState: gameState,
      row: row,
      col: col,
      value: value,
      isMarkMode: gameState.isMarkMode,
    );
    gameState = newState;
    notifyListeners();
  }
  
  Future<void> toggleCandidateInternal(
    int row,
    int col,
    int candidate,
  ) async {
    final newState = gameService.setCellValue(
      gameState: gameState,
      row: row,
      col: col,
      value: candidate,
      isMarkMode: true,
    );
    gameState = newState;
    notifyListeners();
  }
  
  Future<void> clearCellInternal(
    int row,
    int col,
  ) async {
    final cell = gameState.board.getCell(row, col);
    if (cell.isFixed) return;
    
    if (cell.value != null) {
      await setCellValueInternal(row, col, null);
    } else if (cell.candidates.isNotEmpty) {
      final newBoard = gameState.board.setCellCandidates(row, col, <int>{});
      gameState = gameState.updateBoard(newBoard);
      notifyListeners();
    }
  }
  
  void onGameCompleted() {}
  
  Future<void> undo() async {
    if (gameState.canUndo()) {
      gameState = gameState.undo();
      notifyListeners();
    }
  }
  
  Future<void> redo() async {
    if (gameState.canRedo()) {
      gameState = gameState.redo();
      notifyListeners();
    }
  }
  
  void clearHistory() {
    final currentBoard = gameState.board;
    gameState = gameState.copyWith(
      history: [currentBoard],
      historyIndex: 0,
    );
    notifyListeners();
  }
  
  int get historyLength => gameState.history.length;
  int get historyIndex => gameState.historyIndex;
  bool get canUndo => gameState.canUndo();
  bool get canRedo => gameState.canRedo();
}
