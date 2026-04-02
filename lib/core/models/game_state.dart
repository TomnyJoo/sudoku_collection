import 'package:sudoku/core/models/board.dart';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/models/difficulty.dart';

/// 游戏状态具体类，表示整个游戏的当前状态，包括棋盘、答案、计时、历史记录等信息
class GameState {

  /// 构造游戏状态
  GameState({
    required this.board,
    required this.initialBoard,
    required this.solution,
    required this.difficulty,
    this.elapsedTime = 0,
    this.mistakes = 0,
    this.isCompleted = false,
    final List<Board>? history,
    this.historyIndex = 0,
    final Map<int, int>? numberCounts,
    this.startTime,
    this.completionTime,
    this.isShowingSolution = false,
    this.isMarkMode = false,
    this.isAutoMarkMode = false,
    this.hintsUsed = 0,
  })  : history = history ?? [initialBoard],
        numberCounts = numberCounts ?? _calculateNumberCounts(board) {
    // 验证参数
    if (elapsedTime < 0) {
      final errorMsg = '已消耗时间不能为负数: $elapsedTime';
      throw ArgumentError(errorMsg);
    }
    
    if (mistakes < 0) {
      final errorMsg = '错误次数不能为负数: $mistakes';
      throw ArgumentError(errorMsg);
    }
    
    final effectiveHistory = history ?? [initialBoard];
    if (historyIndex < 0 || historyIndex >= effectiveHistory.length) {
      final errorMsg = '历史记录索引超出范围: $historyIndex (范围: 0-${effectiveHistory.length - 1})';
      throw RangeError(errorMsg);
    }
    
    if (completionTime != null && startTime != null && completionTime!.isBefore(startTime!)) {
      const errorMsg = '完成时间不能早于开始时间';
      throw ArgumentError(errorMsg);
    }
  }

  /// 从JSON创建游戏状态（需要子类实现 Board.fromJson）
  factory GameState.fromJson() {
    throw UnimplementedError('GameState.fromJson() requires Board subclass implementation');
  }
  
  final Board board;  /// 当前游戏棋盘
  final Board initialBoard;  /// 初始谜题棋盘（用于重置游戏）
  final Board solution; /// 完整答案棋盘（仅用于显示答案，不可编辑）
  final String difficulty;  /// 游戏难度等级
  final int elapsedTime;  /// 已消耗时间（秒）  
  final int mistakes;  /// 错误计数（违反数独规则的次数）
  final bool isCompleted;  /// 是否完成游戏标志
  final List<Board> history;  /// 历史记录列表
  final int historyIndex;  /// 当前历史记录索引
  final Map<int, int> numberCounts;  /// 数字使用次数统计映射，键为数字，值为使用次数
  final DateTime? startTime;  /// 游戏开始时间
  final DateTime? completionTime;  /// 游戏完成时间
  final bool isShowingSolution;  /// 是否正在显示答案
  final bool isMarkMode;  /// 是否处于标记模式
  final bool isAutoMarkMode;  /// 是否处于自动标记模式
  final int hintsUsed;  /// 使用提示的次数
  
  /// 最大历史记录数量（防止内存泄漏）
  static const int maxHistorySize = 50;

  /// 静态方法计算数字使用次数，避免在构造函数中调用实例方法
  static Map<int, int> _calculateNumberCounts(Board board) {
    final counts = <int, int>{};
    for (var i = 1; i <= board.size; i++) {
      counts[i] = 0;
    }
    
    for (final row in board.cells) {
      for (final cell in row) {
        if (cell.value != null) {
          counts[cell.value!] = (counts[cell.value!] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  /// 复制游戏状态，允许覆盖指定属性
  GameState copyWith({
    Board? board,
    Board? initialBoard,
    Board? solution,
    String? difficulty,
    int? elapsedTime,
    int? mistakes,
    bool? isCompleted,
    List<Board>? history,
    int? historyIndex,
    Map<int, int>? numberCounts,
    DateTime? startTime,
    DateTime? completionTime,
    bool? isShowingSolution,
    bool? isMarkMode,
    bool? isAutoMarkMode,
    int? hintsUsed,
  }) => createInstance(
      board: board ?? this.board,
      initialBoard: initialBoard ?? this.initialBoard,
      solution: solution ?? this.solution,
      difficulty: difficulty ?? this.difficulty,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      mistakes: mistakes ?? this.mistakes,
      isCompleted: isCompleted ?? this.isCompleted,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      numberCounts: numberCounts ?? this.numberCounts,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      isShowingSolution: isShowingSolution ?? this.isShowingSolution,
      isMarkMode: isMarkMode ?? this.isMarkMode,
      isAutoMarkMode: isAutoMarkMode ?? this.isAutoMarkMode,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );

  /// 创建游戏状态实例
  GameState createInstance({
    required Board board,
    required Board initialBoard,
    required Board solution,
    required String difficulty,
    int elapsedTime = 0,
    int mistakes = 0,
    bool isCompleted = false,
    List<Board>? history,
    int historyIndex = 0,
    Map<int, int>? numberCounts,
    DateTime? startTime,
    DateTime? completionTime,
    bool isShowingSolution = false,
    bool isMarkMode = false,
    bool isAutoMarkMode = false,
    int hintsUsed = 0,
  }) => GameState(
      board: board,
      initialBoard: initialBoard,
      solution: solution,
      difficulty: difficulty,
      elapsedTime: elapsedTime,
      mistakes: mistakes,
      isCompleted: isCompleted,
      history: history,
      historyIndex: historyIndex,
      numberCounts: numberCounts,
      startTime: startTime,
      completionTime: completionTime,
      isShowingSolution: isShowingSolution,
      isMarkMode: isMarkMode,
      isAutoMarkMode: isAutoMarkMode,
      hintsUsed: hintsUsed,
    );

  /// 更新棋盘状态
  GameState updateBoard(final Board newBoard) {
    if (isShowingSolution) {
      return this;
    }
    
    final newHistory = history.sublist(0, historyIndex + 1)
    ..add(newBoard);

    int newHistoryIndex = newHistory.length - 1;
    
    // 限制历史记录大小，防止内存泄漏
    if (newHistory.length > maxHistorySize) {
      newHistory.removeAt(0);
      newHistoryIndex--;
    }

    return copyWith(
      board: newBoard,
      history: newHistory,
      historyIndex: newHistoryIndex,
      numberCounts: _calculateNumberCounts(newBoard),
    );
  }

  /// 撤销操作
  GameState undo() {
    if (isShowingSolution) {
      return this;
    }
    
    if (historyIndex <= 0) return this;

    final prevIndex = historyIndex - 1;
    return copyWith(
      board: history[prevIndex],
      historyIndex: prevIndex,
    );
  }

  /// 重做操作
  GameState redo() {
    if (isShowingSolution) {
      return this;
    }
    
    if (historyIndex >= history.length - 1) return this;

    final nextIndex = historyIndex + 1;
    return copyWith(
      board: history[nextIndex],
      historyIndex: nextIndex,
    );
  }

  /// 检查是否可以撤销
  bool canUndo() => !isShowingSolution && historyIndex > 0;

  /// 检查是否可以重做
  bool canRedo() => !isShowingSolution && historyIndex < history.length - 1;

  /// 清空历史记录（保留当前状态）
  GameState clearHistory() => 
    copyWith(
      history: [board],
      historyIndex: 0,
    );

  /// 重置游戏到初始状态
  GameState resetGame() => 
    copyWith(
      board: initialBoard,
      elapsedTime: 0,
      mistakes: 0,
      isCompleted: false,
      history: [initialBoard],
      historyIndex: 0,
      numberCounts: _calculateNumberCounts(initialBoard),
      startTime: DateTime.now(),
      isShowingSolution: false,
      isMarkMode: false,
      isAutoMarkMode: false,
    );

  /// 显示完整答案
  GameState showSolution() {
    final boardCopy = board.copyWith();
    final newHistory = history.sublist(0, historyIndex + 1)
    ..add(boardCopy);
    final newHistoryIndex = newHistory.length - 1;
    
    final solutionBoard = _createSolutionBoardWithFixedFlags();
    
    return copyWith(
      board: solutionBoard,
      isShowingSolution: true,
      history: newHistory,
      historyIndex: newHistoryIndex,
    );
  }
  
  /// 创建带有正确isFixed标记的答案棋盘
  Board _createSolutionBoardWithFixedFlags() {
    final size = solution.size;
    final newCells = <List<Cell>>[];
    
    for (int row = 0; row < size; row++) {
      final rowCells = <Cell>[];
      for (int col = 0; col < size; col++) {
        final solutionCell = solution.getCell(row, col);
        final initialCell = initialBoard.getCell(row, col);
        
        rowCells.add(Cell(
          row: row,
          col: col,
          value: solutionCell.value,
          isFixed: initialCell.isFixed,
          candidates: const {},
        ));
      }
      newCells.add(rowCells);
    }
    
    return solution.createInstance(newCells, regions: solution.regions);
  }

  /// 隐藏答案，返回游戏状态
  GameState hideSolution() {
    // 确保使用有效的棋盘状态，避免返回空白棋盘
    // historyIndex 指向的是保存的当前棋盘状态（查看答案前的状态）
    // 需要恢复到 historyIndex - 1 的状态（查看答案前的上一个状态）
    final currentBoard = history.isNotEmpty && historyIndex > 0 
        ? history[historyIndex - 1] // 恢复到查看答案之前的状态
        : history.isNotEmpty && historyIndex < history.length
          ? history[historyIndex]
          : board;
    return copyWith(
      board: currentBoard,
      isShowingSolution: false,
      // 恢复historyIndex到查看答案之前的位置
      historyIndex: historyIndex > 0 ? historyIndex - 1 : 0,
    );
  }

  /// 增加错误计数
  GameState incrementMistakes() => 
    copyWith(mistakes: mistakes + 1);

  /// 更新已消耗时间
  GameState updateElapsedTime(final int newElapsedTime) => 
    copyWith(elapsedTime: newElapsedTime);

  /// 标记游戏完成
  GameState markCompleted() => 
    copyWith(
      isCompleted: true,
      completionTime: DateTime.now(),
    );

  /// 切换标记模式
  GameState toggleMarkMode() => copyWith(isMarkMode: !isMarkMode);

  /// 切换自动标记模式
  GameState toggleAutoMarkMode() => copyWith(isAutoMarkMode: !isAutoMarkMode);

  /// 获取游戏准确率
  double get accuracy {
    final totalMoves = history.length - 1; // 减去初始状态
    if (totalMoves <= 0) return 1.0;
    
    final correctMoves = totalMoves - mistakes;
    return correctMoves / totalMoves;
  }

  /// 获取游戏完成百分比
  double get completionPercentage {
    final totalCells = board.size * board.size;
    final filledCells = board.getFilledCells().length;
    return filledCells / totalCells;
  }

  /// 获取选中的单元格
  Cell? getSelectedCell() {
    for (final row in board.cells) {
      for (final cell in row) {
        if (cell.isSelected) {
          return cell;
        }
      }
    }
    return null;
  }

  /// 转换为JSON格式，用于持久化存储，返回包含游戏状态数据的Map
  Map<String, dynamic> toJson() => {
      'board': board.toJson(),
      'initialBoard': initialBoard.toJson(),
      'solution': solution.toJson(),
      'difficulty': difficulty,
      'elapsedTime': elapsedTime,
      'mistakes': mistakes,
      'isCompleted': isCompleted,
      'history': history.map((final b) => b.toJson()).toList(),
      'historyIndex': historyIndex,
      'numberCounts': numberCounts.map((key, value) => MapEntry(key.toString(), value)),
      'startTime': startTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'isShowingSolution': isShowingSolution,
      'isMarkMode': isMarkMode,
      'isAutoMarkMode': isAutoMarkMode,
      'hintsUsed': hintsUsed,
    };

  /// 解析通用 JSON 字段的辅助方法
  /// 子类在实现 fromJson 时可以调用此方法获取通用字段
  static Map<String, dynamic> parseCommonJsonFields(Map<String, dynamic> json) {
    final numberCountsJson = json['numberCounts'] as Map<String, dynamic>?;
    final numberCounts = numberCountsJson != null
        ? numberCountsJson.map((key, value) => MapEntry(int.parse(key), value as int))
        : <int, int>{};
    
    final historyIndex = json['historyIndex'] as int? ?? 0;
    final historyJson = json['history'] as List? ?? [];
    
    // 确保 historyIndex 不超过历史记录长度
    // 注意：负数在正常情况下不应该出现，如果出现说明数据已损坏
    final safeHistoryIndex = historyIndex >= historyJson.length
        ? (historyJson.isEmpty ? 0 : historyJson.length - 1)
        : historyIndex;
    
    return {
      'difficulty': json['difficulty'] as String? ?? 'medium',
      'elapsedTime': json['elapsedTime'] as int? ?? 0,
      'mistakes': json['mistakes'] as int? ?? 0,
      'isCompleted': json['isCompleted'] as bool? ?? false,
      'historyIndex': safeHistoryIndex,
      'numberCounts': numberCounts,
      'startTime': json['startTime'] != null 
          ? DateTime.parse(json['startTime'] as String) 
          : null,
      'completionTime': json['completionTime'] != null 
          ? DateTime.parse(json['completionTime'] as String) 
          : null,
      'isShowingSolution': json['isShowingSolution'] as bool? ?? false,
      'isMarkMode': json['isMarkMode'] as bool? ?? false,
      'isAutoMarkMode': json['isAutoMarkMode'] as bool? ?? false,
      'hintsUsed': json['hintsUsed'] as int? ?? 0,
    };
  }

  /// 获取用于调试的字符串表示（不依赖国际化）
  String toDebugString() {
    final timeStr = _formatTime(elapsedTime);
    return 'GameState(difficulty: $difficulty, time: $timeStr, '
        'mistakes: $mistakes, completed: $isCompleted, history: ${history.length}, showingSolution: $isShowingSolution, '
        'isMarkMode: $isMarkMode, isAutoMarkMode: $isAutoMarkMode)';
  }

  /// 获取用于显示的字符串表示（考虑国际化）
  String toDisplayString({final dynamic localizations}) {
    final timeStr = _formatTime(elapsedTime);
    
    // 使用本地化字符串或默认值
    final gameStatusText = _getLocalizedGameStatusText(localizations);
    final difficultyText = _getLocalizedDifficultyText(localizations);
    final timeLabel = _getLocalizedTimeLabel(localizations);
    final mistakesLabel = _getLocalizedMistakesLabel(localizations);
    final accuracyLabel = _getLocalizedAccuracyLabel(localizations);
    final completionLabel = _getLocalizedCompletionLabel(localizations);
    final statusLabel = _getLocalizedStatusLabel(localizations);
    
    final accuracyPercent = (accuracy * 100).toStringAsFixed(1);
    final completionPercent = (completionPercentage * 100).toStringAsFixed(1);
    
    return '$gameStatusText: $difficultyText, $timeLabel: $timeStr, $mistakesLabel: $mistakes, '
        '$accuracyLabel: $accuracyPercent%, $completionLabel: $completionPercent%, $statusLabel: ${_getLocalizedStatusValue(localizations)}';
  }

  /// 获取本地化的游戏状态文本
  String _getLocalizedGameStatusText(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations['gameStatus'] ?? '游戏状态';
      }
    } catch (e) {
      // 忽略异常
    }
    return '游戏状态';
  }

  /// 获取本地化的难度文本
  String _getLocalizedDifficultyText(final dynamic localizations) {
    try {
      if (localizations is Map) {
        const difficultyKey = 'difficulty';
        final difficultyValue = _getLocalizedDifficultyValue(localizations);
        return localizations.containsKey(difficultyKey) 
            ? '${localizations[difficultyKey]}: $difficultyValue'
            : '$difficultyValue难度';
      }
    } catch (e) {
      // 忽略异常
    }
    return '$difficulty难度';
  }

  /// 获取本地化的难度值
  String _getLocalizedDifficultyValue(final dynamic localizations) {
    try {
      if (localizations is Map) {
        if (difficulty == Difficulty.beginner.toString()) {
          return localizations['difficultyBeginner'] ?? '初级';
        } else if (difficulty == Difficulty.easy.toString()) {
          return localizations['difficultyEasy'] ?? '简单';
        } else if (difficulty == Difficulty.medium.toString()) {
          return localizations['difficultyMedium'] ?? '中等';
        } else if (difficulty == Difficulty.hard.toString()) {
          return localizations['difficultyHard'] ?? '困难';
        } else if (difficulty == Difficulty.expert.toString()) {
          return localizations['difficultyExpert'] ?? '专家';
        } else if (difficulty == Difficulty.master.toString()) {
          return localizations['difficultyMaster'] ?? '大师';
        } else if (difficulty == Difficulty.custom.toString()) {
          return localizations['difficultyCustom'] ?? '自定义';
        }
      }
    } catch (e) {
      // 忽略异常
    }
    return difficulty;
  }

  /// 获取本地化的时间标签
  String _getLocalizedTimeLabel(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations['time'] ?? '用时';
      }
    } catch (e) {
      // 忽略异常
    }
    return '用时';
  }

  /// 获取本地化的错误标签
  String _getLocalizedMistakesLabel(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations['mistakes'] ?? '错误';
      }
    } catch (e) {
      // 忽略异常
    }
    return '错误';
  }

  /// 获取本地化的准确率标签
  String _getLocalizedAccuracyLabel(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations['accuracy'] ?? '准确率';
      }
    } catch (e) {
      // 忽略异常
    }
    return '准确率';
  }

  /// 获取本地化的完成度标签
  String _getLocalizedCompletionLabel(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations['completion'] ?? '完成度';
      }
    } catch (e) {
      // 忽略异常
    }
    return '完成度';
  }

  /// 获取本地化的状态标签
  String _getLocalizedStatusLabel(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations['status'] ?? '状态';
      }
    } catch (e) {
      // 忽略异常
    }
    return '状态';
  }

  /// 获取本地化的状态值
  String _getLocalizedStatusValue(final dynamic localizations) {
    try {
      if (localizations is Map) {
        if (isShowingSolution) {
          return localizations['showingSolution'] ?? '显示答案中';
        } else if (isCompleted) {
          return localizations['completed'] ?? '已完成';
        } else {
          return localizations['inProgress'] ?? '进行中';
        }
      }
    } catch (e) {
      // 忽略异常
    }
    if (isShowingSolution) {
      return '显示答案中';
    }
    return isCompleted ? '已完成' : '进行中';
  }

  /// 格式化时间（秒转换为分钟:秒格式）
  String _formatTime(final int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.difficulty == difficulty &&
        other.isCompleted == isCompleted &&
        other.isMarkMode == isMarkMode &&
        other.isAutoMarkMode == isAutoMarkMode;
  }

  @override
  int get hashCode => Object.hash(difficulty, isCompleted, isMarkMode, isAutoMarkMode);

  @override
  String toString() => toDebugString();
}
