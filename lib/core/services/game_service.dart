import 'package:meta/meta.dart';
import 'package:sudoku/core/index.dart';

/// 用于返回更新后的棋盘和错误数量的辅助类
class BoardUpdateResult {
  BoardUpdateResult(this.board, this.mistakes);
  final Board board;
  final int mistakes;
}

/// 通用游戏服务抽象基类，负责游戏状态管理、持久化和用户操作
/// 整合 GameLogic 处理游戏规则，本身不重复逻辑
///
/// 重构说明：
/// - 提供大部分方法的默认实现
/// - 子类只需实现持久化相关方法（saveGameState, loadGameState 等）
/// - 特殊游戏（如 Samurai）可重写需要的方法
abstract class GameService {
  GameService({required this.gameType, required GameValidator validator})
    : _validator = validator;

  final String gameType;
  final GameValidator _validator;

  /// 生成新游戏
  Future<GameState> generateGame({
    required Difficulty difficulty,
    int? size,
    final Map<String, dynamic>? options,
    Function(GenerationStage)? onStageUpdate,
  }) async {
    final isCancelled = options?['isCancelled'] as bool Function()?;

    final gameTypeEnum = _parseGameType(gameType);
    // 武士数独默认使用21x21棋盘
    final boardSize = size ?? (gameTypeEnum == GameType.samurai ? 21 : 9);

    GenerationResult result;

    // 使用游戏生成门面
    result = await GameGenerationFacade.generateGame(
      gameType: gameTypeEnum,
      size: boardSize,
      difficulty: difficulty,
      onStageUpdate: onStageUpdate,
      isCancelled: isCancelled,
    );

    return createGameState(
      puzzle: result.puzzle,
      solution: result.solution,
      difficulty: difficulty,
    );
  }

  /// 解析游戏类型
  GameType _parseGameType(String type) {
    switch (type.toLowerCase()) {
      case 'standard':
        return GameType.standard;
      case 'diagonal':
        return GameType.diagonal;
      case 'window':
        return GameType.window;
      case 'jigsaw':
        return GameType.jigsaw;
      case 'killer':
        return GameType.killer;
      case 'samurai':
        return GameType.samurai;
      default:
        return GameType.standard;
    }
  }

  /// 创建游戏状态 - 由子类实现以返回具体的游戏状态类型
  GameState createGameState({
    required Board puzzle,
    required Board solution,
    required Difficulty difficulty,
  }) {
    // 确保棋盘有区域（容错机制）
    final finalPuzzle = puzzle.regions.isEmpty 
        ? puzzle.createInstance(puzzle.cells, regions: puzzle.createRegions())
        : puzzle;
    
    final finalSolution = solution.regions.isEmpty
        ? solution.createInstance(solution.cells, regions: solution.createRegions())
        : solution;
    
    return createSpecificGameState(
      finalPuzzle,
      finalSolution,
      difficulty,
    );
  }
  
  /// 创建特定游戏类型的游戏状态
  /// 子类必须实现此方法
  @protected
  GameState createSpecificGameState(
    Board puzzle,
    Board solution,
    Difficulty difficulty,
  ) => GameState(
      board: puzzle,
      initialBoard: puzzle,
      solution: solution,
      startTime: DateTime.now(),
      difficulty: difficulty.name,
    );

  /// 检查游戏是否完成
  bool isGameCompleted(GameState state) => state.board.isComplete();

  /// 检查游戏是否有效
  bool isGameValid(GameState state) => _validator.validateBoard(state.board);

  /// 保存游戏状态（由子类实现）
  Future<void> saveGameState(GameState state);

  /// 加载游戏状态（由子类实现）
  Future<GameState?> loadGameState(String gameId);

  /// 删除游戏状态（由子类实现）
  Future<void> deleteGameState(String gameId);

  /// 清除保存的游戏（与 deleteGameState 相同，用于兼容）
  Future<void> clearSavedGame(String gameId) => deleteGameState(gameId);

  /// 获取所有保存的游戏（由子类实现）
  Future<List<GameState>> getAllSavedGames();

  /// 检查游戏是否有保存的状态（由子类实现）
  Future<bool> hasSavedGame(String gameId);

  /// 重置游戏状态
  GameState resetGame(GameState state) => state.resetGame();

  /// 更新游戏时间
  GameState updateTime(GameState state, Duration timeElapsed) =>
      state.updateElapsedTime(timeElapsed.inSeconds);

  /// 暂停/恢复游戏
  // ignore: prefer_expression_function_bodies
  GameState togglePause(GameState state) {
    // GameState 目前不支持暂停功能，直接返回原状态
    return state;
  }

  /// 标记游戏为完成
  GameState markAsCompleted(GameState state) => state.markCompleted();

  /// 记录使用提示
  // ignore: prefer_expression_function_bodies
  GameState recordHintUsed(GameState state) {
    // GameState 目前不支持 hintsUsed 功能，直接返回原状态
    return state;
  }

  /// 记录错误
  GameState recordMistake(GameState state) => state.incrementMistakes();

  /// 检查移动是否有效
  bool isValidMove(GameState state, int row, int col, int value) =>
      _validator.isValidMove(state.board, row, col, value);

  /// 检查移动是否正确
  bool isCorrectMove(GameState state, int row, int col, int value) {
    final solutionValue = state.solution.getCell(row, col).value;
    return solutionValue == value;
  }

  /// 检查单元格是否已固定
  bool isCellFixed(GameState state, int row, int col) =>
      state.board.getCell(row, col).isFixed;

  /// 检查单元格是否有值
  bool isCellFilled(GameState state, int row, int col) =>
      !state.board.getCell(row, col).isEmpty;

  /// 获取单元格的值
  int? getCellValue(GameState state, int row, int col) =>
      state.board.getCell(row, col).value;

  /// 获取单元格的正确值
  int getCellSolution(GameState state, int row, int col) =>
      state.solution.getCell(row, col).value!;

  /// 获取单元格的候选数
  Set<int> getCellCandidates(GameState state, int row, int col) =>
      state.board.getCell(row, col).candidates;

  /// 清除单元格的候选数
  Board clearCellCandidates(GameState state, int row, int col) =>
      state.board.setCellCandidates(row, col, <int>{});

  /// 检查单元格是否有错误
  bool isCellError(GameState state, int row, int col) =>
      state.board.getCell(row, col).isError;

  /// 标记单元格为错误
  Board markCellAsError(GameState state, int row, int col) =>
      state.board.setCellError(row, col, true);

  /// 清除单元格的错误标记
  Board clearCellError(GameState state, int row, int col) =>
      state.board.setCellError(row, col, false);

  /// 清除所有错误标记
  Board clearAllErrors(GameState state) {
    Board workingBoard = state.board;

    final size = state.board.size;
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        workingBoard = workingBoard.setCellError(row, col, false);
      }
    }

    return workingBoard;
  }

  /// 检查游戏是否有错误
  bool hasErrors(GameState state) {
    final size = state.board.size;
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (state.board.getCell(row, col).isError) {
          return true;
        }
      }
    }
    return false;
  }

  /// 计算游戏进度
  double calculateProgress(GameState state) {
    final filledCount = getFilledCellCount(state);
    final totalCount = getTotalCellCount(state);
    return totalCount > 0 ? filledCount / totalCount : 0.0;
  }

  /// 获取已填充的单元格数量
  int getFilledCellCount(GameState state) =>
      state.board.getFilledCells().length;

  /// 获取总单元格数量
  int getTotalCellCount(GameState state) {
    final size = state.board.size;
    return size * size;
  }

  /// 检查游戏是否可以撤销
  bool canUndo(GameState state) => state.canUndo();

  /// 检查游戏是否可以重做
  bool canRedo(GameState state) => state.canRedo();

  /// 撤销操作
  GameState undo(GameState state) => state.undo();

  /// 重做操作
  GameState redo(GameState state) => state.redo();

  /// 保存当前状态到历史记录
  void saveStateToHistory(GameState state) {
    // 使用GameState的updateBoard方法保存状态
  }

  /// 清除历史记录
  GameState clearHistory(GameState state) => state.clearHistory();

  // ========== 最佳分数相关方法（使用 BestScoresRepository）==========

  /// 获取最佳成绩仓库（子类需要实现）
  /// 返回 null 表示不支持最佳成绩功能
  BestScoresRepository? get bestScoresRepository => null;

  /// 保存最佳分数
  Future<bool> saveBestScore({
    required String difficulty,
    required int timeInSeconds,
    required int mistakes,
  }) async {
    final repository = bestScoresRepository;
    if (repository == null) return false;

    final score = BestScore(
      time: timeInSeconds,
      mistakes: mistakes,
      timestamp: DateTime.now(),
    );
    return repository.saveBestScore(difficulty, score);
  }

  /// 获取最佳分数
  Future<Map<String, dynamic>?> getBestScore({
    required String difficulty,
  }) async {
    final repository = bestScoresRepository;
    if (repository == null) return null;

    final score = await repository.getBestScore(difficulty);
    if (score == null) return null;

    return {
      'time': score.time,
      'mistakes': score.mistakes,
      'timestamp': score.timestamp.toIso8601String(),
    };
  }

  /// 获取所有难度的最佳分数
  Future<Map<String, Map<String, dynamic>>> getBestScores() async {
    final repository = bestScoresRepository;
    if (repository == null) return {};

    final scores = await repository.getAllBestScores();
    return scores.map(
      (key, value) => MapEntry(key, {
        'time': value.time,
        'mistakes': value.mistakes,
        'timestamp': value.timestamp.toIso8601String(),
      }),
    );
  }

  /// 清除最佳分数
  Future<void> clearBestScores({String? difficulty}) async {
    final repository = bestScoresRepository;
    if (repository == null) return;

    if (difficulty != null) {
      await repository.clearBestScore(difficulty);
    } else {
      await repository.clearBestScores();
    }
  }

  /// 设置单元格值
  GameState setCellValue({
    required GameState gameState,
    required int row,
    required int col,
    required int? value,
    required bool isMarkMode,
  }) {
    final currentCell = gameState.board.getCell(row, col);
    if (currentCell.isFixed) return gameState;

    Board newBoard;
    if (isMarkMode) {
      // 标记模式：切换候选数
      if (value == null) return gameState;
      newBoard = gameState.board.toggleCellCandidate(row, col, value);
    } else {
      // 普通模式：设置值
      newBoard = gameState.board.setCellValue(row, col, value);

      // 验证值是否违反数独规则，标记错误状态
      if (value != null) {
        // 临时移除该值，检查是否可以合法放置
        final tempBoard = gameState.board.setCellValue(row, col, null);
        final isValid = _validator.isValidMove(tempBoard, row, col, value);
        newBoard = newBoard.setCellError(row, col, !isValid);
      }
    }

    // 使用GameState的updateBoard方法更新状态
    var newState = gameState.updateBoard(newBoard);
    
    // 检查游戏是否完成（只在普通模式且游戏未完成时检查）
    if (!isMarkMode && !newState.isCompleted) {
      final tempState = newState.copyWith(board: newBoard);
      if (isGameCompleted(tempState)) {
        newState = markAsCompleted(newState);
      }
    }
    
    return newState;
  }

  /// 清除单元格值
  GameState clearCellValue({
    required GameState gameState,
    required int row,
    required int col,
  }) => setCellValue(
    gameState: gameState,
    row: row,
    col: col,
    value: null,
    isMarkMode: false,
  );
}
