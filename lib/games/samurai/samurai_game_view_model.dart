import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/samurai/index.dart';

class SamuraiGameViewModel extends GameViewModel<SamuraiGameState> {
  SamuraiGameViewModel([AppSettings? settings])
    : super(_createInitialState(), SamuraiGameService(), settings ?? AppSettings());

  factory SamuraiGameViewModel.withState(SamuraiGameState state, [AppSettings? settings]) => SamuraiGameViewModel._internal(state, SamuraiGameService(), settings ?? AppSettings());

  SamuraiGameViewModel._internal(super.state, super.service, super.settings);

  SamuraiGameService get _samuraiGameService => gameService as SamuraiGameService;

  static SamuraiGameState _createInitialState() {
    final emptyBoard = SamuraiBoard.empty();
    return SamuraiGameState(
      board: emptyBoard,
      initialBoard: emptyBoard,
      solution: emptyBoard,
      difficulty: Difficulty.medium,
    );
  }

  @override
  SamuraiGameState get state => gameState as SamuraiGameState;

  int get currentSubGridIndex => state.currentSubGridIndex;

  bool get isOverviewMode => state.isOverviewMode;

  void toggleOverviewMode() {
    gameState = state.toggleOverviewMode();
    notifyListeners();
  }

  void enterOverviewMode() {
    if (!state.isOverviewMode) {
      gameState = state.toggleOverviewMode();
      notifyListeners();
    }
  }

  void exitOverviewMode() {
    if (state.isOverviewMode) {
      gameState = state.toggleOverviewMode();
      notifyListeners();
    }
  }

  @override
  int? getNumberCount(int number) => state.getSubGridNumberCounts(currentSubGridIndex)[number];

  Future<void> switchSubGrid(int index) async {
    gameState = state.switchSubGrid(index);
    notifyListeners();
    
    // 如果处于自动候选模式且游戏正在进行中，重新计算候选数
    if (gameState.isAutoMarkMode && isPlaying) {
      await autoMarkCandidates(visibleSubBoards: [index]);
    }
  }

  @override
  @protected
  Future<void> generateNewGame(final Difficulty difficulty) async {
    if (isCancelled) return;

    final newState = await _samuraiGameService.generateGame(
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

  @override
  Future<void> saveGame() async {
    try {
      if (gameState.isCompleted) return;
      if (gameState.startTime == null) return;

      // 检查游戏状态是否有效
      if (_isValidGameState(gameState as SamuraiGameState)) {
        await _samuraiGameService.saveGameState(gameState);
      }
    } catch (e) {
      debugPrint('Save game error: $e');
    }
  }

  /// 检查游戏状态是否有效
  bool _isValidGameState(SamuraiGameState state) {
    // 检查基本字段
    if (state.startTime == null) return false;
    if (state.isCompleted) return false;
    
    // 检查游戏数据
    if (state.board.cells.isEmpty) return false;
    
    return true;
  }

  @override
  Future<void> loadGame() async {
    try {
      final saveKey = '${_samuraiGameService.gameType}_current';

      final savedState = await _samuraiGameService.loadGameState(saveKey);
      if (savedState != null && !savedState.isCompleted && savedState.startTime != null) {
        gameState = savedState;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load game error: $e');
    }
  }

  @override
  @protected
  void onSettingsChanged() {
    if (gameState.isAutoMarkMode && isPlaying) {
      autoMarkCandidates(visibleSubBoards: [currentSubGridIndex]);
    }
  }

  @override
  Future<void> setCellValue(
    final int row,
    final int col,
    final int? value,
  ) async {
    if (!isPlaying) return;
    try {
      await setCellValueInternal(row, col, value);
      
      // 检查游戏是否完成
      if (gameState.isCompleted) {
        // 停止计时器
        gameTimer.pause();
        // 播放完成音效
        if (PlatformDispatcher.instance.implicitView != null) {
          final audioManager = AudioManager();
          await audioManager.playCompleteSound();
        }
      }
      
      notifyListeners();
      
      // 自动标记模式下重新计算候选数（仅在游戏未完成时）
      if (gameState.isAutoMarkMode && isPlaying) {
        await autoMarkCandidates(visibleSubBoards: [currentSubGridIndex]);
      }
      
      await saveGame();
    } catch (e) {
      debugPrint('设置单元格值失败: $e');
    }
  }

  @override
  Future<void> clearCellValue() async {
    final selectedCell = gameState.getSelectedCell();
    if (selectedCell != null) {
      await clearCellInternal(selectedCell.row, selectedCell.col);
      
      // 自动标记模式下重新计算候选数
      if (gameState.isAutoMarkMode && isPlaying) {
        await autoMarkCandidates(visibleSubBoards: [currentSubGridIndex]);
      }
      
      await saveGame();
    }
  }

  @override
  Future<void> toggleAutoMarkMode() async {
    // 先切换状态
    gameState = state.toggleAutoMarkMode();
    notifyListeners();

    // 如果开启了自动标记模式，立即触发候选数计算
    if (gameState.isAutoMarkMode && isPlaying) {
      await autoMarkCandidates(visibleSubBoards: [currentSubGridIndex]);
    } else if (!gameState.isAutoMarkMode) {
      // 如果关闭了自动标记模式，清除所有候选数
      await clearAllCandidates();
    }
  }

  @override
  Future<void> onClear() async {
    final selectedCell = gameState.getSelectedCell();
    if (selectedCell == null || selectedCell.isFixed) return;

    if (selectedCell.value != null) {
      await setCellValueInternal(
        selectedCell.row,
        selectedCell.col,
        null,
      );
      
      if (gameState.isAutoMarkMode && isPlaying) {
        await autoMarkCandidates(visibleSubBoards: [currentSubGridIndex]);
      }
    } else if (selectedCell.candidates.isNotEmpty) {
      final newBoard = gameState.board.setCellCandidates(
        selectedCell.row,
        selectedCell.col,
        <int>{},
      );
      gameState = gameState.updateBoard(newBoard);

      if (gameState.isAutoMarkMode && isPlaying) {
        await autoMarkCandidates(visibleSubBoards: [currentSubGridIndex]);
      }
    }
    notifyListeners();
  }
}
