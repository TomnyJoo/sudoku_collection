import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

abstract class GameViewModel<T extends GameState> extends ChangeNotifier
    with
        GameStateMixin,
        GameLifecycleMixin,
        GameInputMixin,
        GameAssistMixin,
        GamePersistenceMixin {
  GameViewModel(this._gameState, this._gameService, [this._appSettings]) {
    _gameTimer = GameTimer(
      onTick: () {
        if (!gameState.isCompleted) {
          gameState = gameState.copyWith(elapsedTime: _gameTimer.elapsedTime) as T;
          notifyListeners();
        }
      },
      onComplete: () async {
        gameState = gameState.copyWith(isCompleted: true) as T;
        notifyListeners();
      },
    );
  }
  final GameService _gameService;

  AppSettings? _appSettings;

  late final GameTimer _gameTimer;

  bool _isLoading = false;

  bool _isCancelled = false;

  GenerationStage _generationStage = GenerationStage.generatingSolution;

  // Mixin 需要的 getter/setter 实现
  @override
  GameState get gameState => _gameState;
  @override
  set gameState(GameState value) {
    _gameState = value as T;
  }

  T _gameState;

  @override
  GameTimer get gameTimer => _gameTimer;

  @override
  GameService get gameService => _gameService;

  @override
  AppSettings? get settings => _appSettings;

  @override
  bool get isPlaying => gameState.startTime != null && !gameState.isCompleted;

  @override
  bool get useAdvancedStrategy => _appSettings?.useAdvancedStrategy ?? true;

  @override
  bool get isLoading => _isLoading;
  @override
  set isLoading(bool value) => _isLoading = value;

  @override
  bool get isCancelled => _isCancelled;
  @override
  set isCancelled(bool value) => _isCancelled = value;

  @override
  GenerationStage get generationStage => _generationStage;
  @override
  set generationStage(GenerationStage value) => _generationStage = value;

  GameState get currentGameState => gameState;

  /// 获取类型化的状态（子类可重写）
  GameState get state => gameState;

  /// 更新游戏设置
  void updateSettings(AppSettings settings) {
    _appSettings = settings;
    onSettingsChanged();
    notifyListeners();
  }

  /// 当设置变化时调用（子类可以重写）
  @protected
  void onSettingsChanged() {
    if (gameState.isAutoMarkMode && isPlaying) {
      autoMarkCandidates();
    }
  }

  // ========== 游戏生命周期方法（委托给 Mixin）==========

  /// 开始新游戏
  Future<void> startNewGame(final Difficulty difficulty) =>
      startNewGameInternal(difficulty,
          generateNewGame: generateNewGame,
          resetGameState: resetGameState);

  /// 暂停游戏
  Future<void> pauseGame({bool notify = true}) => pauseGameInternal(notify: notify);

  /// 恢复游戏
  Future<void> resumeGame() => resumeGameInternal();

  /// 重置游戏
  @override
  Future<void> resetGame() => super.resetGame();

  /// 保存游戏状态（异步）
  Future<void> saveGame() => saveGameInternal();

  /// 保存游戏状态（同步）
  void saveGameSync() => saveGameSyncInternal();

  /// 加载游戏状态
  Future<void> loadGame() => loadGameInternal();

  /// 加载指定的游戏状态
  void loadGameState(GameState state) {
    gameState = state;
    gameTimer.setElapsedTime(state.elapsedTime);
    if (state.startTime != null && !state.isCompleted) {
      gameTimer.start();
    }
    notifyListeners();
  }

  /// 取消游戏生成
  void cancelGameGeneration() => cancelGameGenerationInternal();

  // ========== 单元格操作方法（委托给 Mixin）==========

  /// 处理单元格点击
  Future<void> handleCellTap(final int row, final int col) async {
    if (!isPlaying) return;
    try {
      await handleCellSelectionInternal(row, col);
      notifyListeners();
    } catch (e) {
      _handleError('处理单元格点击失败', e);
    }
  }

  /// 选择单元格
  void selectCell(final int row, final int col) => handleCellTap(row, col);

  /// 单元格被点击
  void cellTapped(final int row, final int col) => handleCellTap(row, col);

  /// 通过 Cell 对象选择单元格
  void selectCellByObject(Cell cell) => handleCellTap(cell.row, cell.col);

  /// 输入数字
  void inputNumber(final int number) {
    final selectedCell = gameState.getSelectedCell();
    if (selectedCell != null) {
      setCellValue(selectedCell.row, selectedCell.col, number);
    }
  }

  /// 设置单元格值
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
        await autoMarkCandidates();
      }
      
      await saveGame();
    } catch (e) {
      _handleError('设置单元格值失败', e);
    }
  }

  /// 设置当前选中单元格的值
  Future<void> setCellValueByNumber(int? value) async {
    if (!isPlaying) return;
    final selectedCell = gameState.getSelectedCell();
    if (selectedCell != null) {
      if (gameState.isMarkMode && value != null) {
        await toggleCandidate(selectedCell.row, selectedCell.col, value);
      } else {
        await setCellValue(selectedCell.row, selectedCell.col, value);
      }
    }
  }

  /// 切换候选数标记
  Future<void> toggleCandidate(
    final int row,
    final int col,
    final int candidate,
  ) async {
    if (!isPlaying) return;
    try {
      await toggleCandidateInternal(row, col, candidate);
      notifyListeners();
      await saveGame();
    } catch (e) {
      _handleError('切换候选数失败', e);
    }
  }

  /// 清除输入
  Future<void> clearInput() => onClear();

  /// 清除当前选中单元格的值
  Future<void> clearCellValue() async {
    final selectedCell = gameState.getSelectedCell();
    if (selectedCell != null) {
      await clearCellInternal(selectedCell.row, selectedCell.col);
      
      // 自动标记模式下重新计算候选数
      if (gameState.isAutoMarkMode && isPlaying) {
        await autoMarkCandidates();
      }
      
      await saveGame();
    }
  }

  // ========== 功能键盘相关方法（委托给 Mixin）==========

  /// 撤销
  @override
  Future<void> undo() async => super.undo();

  /// 重做
  @override
  Future<void> redo() async => super.redo();

  /// 提示
  @override
  Future<void> hint(BuildContext context) async => super.hint(context);

  /// 切换标记模式
  @override
  Future<void> toggleMarkMode() async => super.toggleMarkMode();

  /// 切换自动标记模式
  @override
  Future<void> toggleAutoMarkMode() async {
    // 先切换状态
    gameState = gameState.toggleAutoMarkMode();
    notifyListeners();

    // 如果开启了自动标记模式，立即触发候选数计算
    if (gameState.isAutoMarkMode && isPlaying) {
      await autoMarkCandidates();
    } else if (!gameState.isAutoMarkMode) {
      // 如果关闭了自动标记模式，清除所有候选数
      await clearAllCandidates();
    }
  }

  /// 切换显示答案
  @override
  Future<void> toggleShowSolution() async => super.toggleShowSolution();

  // ========== 子类必须实现的抽象方法 ==========

  /// 生成新游戏（子类实现）
  @protected
  Future<void> generateNewGame(final Difficulty difficulty);

  /// 重置游戏状态（子类实现）
  @protected
  Future<void> resetGameState();

  /// 处理清除操作（默认实现）
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
        await autoMarkCandidates();
      }
    } else if (selectedCell.candidates.isNotEmpty) {
      final newBoard = gameState.board.setCellCandidates(
        selectedCell.row,
        selectedCell.col,
        <int>{},
      );
      gameState = gameState.updateBoard(newBoard);

      if (gameState.isAutoMarkMode && isPlaying) {
        await autoMarkCandidates();
      }
    }
    notifyListeners();
  }

  // ========== 工具方法 ==========

  /// 获取数字使用次数
  int? getNumberCount(int number) => gameState.numberCounts[number];

  /// 获取本地化的难度字符串
  String getLocalizedDifficulty(BuildContext context) {
    final loc = LocalizationUtils.of(context);
    switch (gameState.difficulty) {
      case 'beginner':
        return loc?.difficultyBeginner ?? 'Beginner';
      case 'easy':
        return loc?.difficultyEasy ?? 'Easy';
      case 'medium':
        return loc?.difficultyMedium ?? 'Medium';
      case 'hard':
        return loc?.difficultyHard ?? 'Hard';
      case 'expert':
        return loc?.difficultyExpert ?? 'Expert';
      case 'master':
        return loc?.difficultyMaster ?? 'Master';
      case 'custom':
        return loc?.difficultyCustom ?? 'Custom';
      default:
        return gameState.difficulty;
    }
  }

  /// 格式化时间显示
  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  /// 处理错误（内部使用）
  void _handleError(final String message, final Object error) {}

  // 实现GameAssistMixin需要的抽象方法
  @override
  Future<void> setCellValueForHint(int row, int col, int value) async {
    await setCellValue(row, col, value);
  }

  /// 释放资源
  @override
  void dispose() {
    disposeAutoMarkTimer();
    disposeSaveTimer();
    _gameTimer.dispose();
    super.dispose();
  }
}
