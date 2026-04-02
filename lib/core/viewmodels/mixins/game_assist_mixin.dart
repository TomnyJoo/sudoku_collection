import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sudoku/common/settings/app_settings.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/samurai/models/samurai_board.dart';

mixin GameAssistMixin on ChangeNotifier {
  GameState get gameState;
  set gameState(GameState value);
  
  bool get isPlaying;
  bool get useAdvancedStrategy;
  AppSettings? get settings;
  
  Timer? autoMarkDebounceTimer;
  bool isCalculatingCandidates = false;
  
  Future<void> autoMarkCandidates({List<int>? visibleSubBoards}) async {
    autoMarkDebounceTimer?.cancel();

    autoMarkDebounceTimer = Timer(GameConstants.autoMarkDebounceDelay, () async {
      if (isCalculatingCandidates) {
        return;
      }

      try {
        isCalculatingCandidates = true;

        if (!hasListeners) {
          return;
        }

        // 计算候选数
        final calculator = CandidateCalculator(gameState.board);
        final candidates = gameState.board is SamuraiBoard && visibleSubBoards != null
            ? calculator.computeSamuraiCandidates(
                visibleSubBoards,
                useAdvancedStrategies: useAdvancedStrategy,
              )
            : calculator.computeAllCandidates(
                useAdvancedStrategies: useAdvancedStrategy,
              );

        // 更新棋盘候选数
        var newBoard = gameState.board;
        
        // 如果是武士数独且有可见子棋盘，只更新可见子棋盘的候选数
        if (gameState.board is SamuraiBoard && visibleSubBoards != null) {
          for (final subBoardIndex in visibleSubBoards) {
            final (startRow, startCol) = SamuraiBoard.subGridOffsets[subBoardIndex];
            for (int row = startRow; row < startRow + 9; row++) {
              for (int col = startCol; col < startCol + 9; col++) {
                final key = '$row,$col';
                if (candidates.containsKey(key)) {
                  newBoard = newBoard.setCellCandidates(row, col, candidates[key]!);
                }
              }
            }
          }
        } else {
          // 否则更新整个棋盘的候选数
          for (int row = 0; row < newBoard.size; row++) {
            for (int col = 0; col < newBoard.size; col++) {
              final key = '$row,$col';
              if (candidates.containsKey(key)) {
                newBoard = newBoard.setCellCandidates(row, col, candidates[key]!);
              }
            }
          }
        }

        gameState = gameState.updateBoard(newBoard);
        notifyListeners();
      } finally {
        isCalculatingCandidates = false;
      }
    });
  }
  
  Future<void> clearAllCandidates() async {
    var newBoard = gameState.board;
    
    for (int row = 0; row < gameState.board.size; row++) {
      for (int col = 0; col < gameState.board.size; col++) {
        final cell = gameState.board.getCell(row, col);
        if (!cell.isFixed && cell.value == null) {
          newBoard = newBoard.setCellCandidates(row, col, <int>{});
        }
      }
    }
    
    gameState = gameState.updateBoard(newBoard);
    notifyListeners();
  }
  
  void disposeAutoMarkTimer() {
    autoMarkDebounceTimer?.cancel();
  }
  
  /// 提示 - 直接填入答案
  Future<void> hint(BuildContext context) async {
    final selectedCell = gameState.getSelectedCell();
    
    // 优先处理选中的单元格
    if (selectedCell != null && selectedCell.value == null && !selectedCell.isFixed) {
      final solutionValue = gameState.solution.getCell(selectedCell.row, selectedCell.col).value;
      if (solutionValue != null) {
        // 选中单元格
        final newBoard = gameState.board.selectCell(selectedCell.row, selectedCell.col);
        gameState = gameState.updateBoard(newBoard);
        
        // 填入答案
        await setCellValueForHint(selectedCell.row, selectedCell.col, solutionValue);
        notifyListeners();
        return;
      }
    }
    
    // 查找第一个空单元格
    for (int row = 0; row < gameState.board.size; row++) {
      for (int col = 0; col < gameState.board.size; col++) {
        final cell = gameState.board.getCell(row, col);
        if (cell.value == null && !cell.isFixed) {
          final solutionValue = gameState.solution.getCell(row, col).value;
          if (solutionValue != null) {
            // 选中单元格
            final newBoard = gameState.board.selectCell(row, col);
            gameState = gameState.updateBoard(newBoard);
            
            // 填入答案
            await setCellValueForHint(row, col, solutionValue);
            notifyListeners();
            return;
          }
        }
      }
    }
    
    // 显示无可用提示的反馈
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('暂无可用的提示'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '关闭',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // 由使用此mixin的类实现
  Future<void> setCellValueForHint(int row, int col, int value);
}
