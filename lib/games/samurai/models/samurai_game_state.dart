import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/samurai/models/samurai_board.dart';

/// 武士数独游戏状态
/// 
/// 优化说明：
/// - 移除冗余字段（redoStack, selectedCell, timeElapsed, status），使用基类机制
/// - 统一使用 copyWith 方法
/// - 添加 isOverviewMode 支持概览模式
class SamuraiGameState extends GameState {

  SamuraiGameState({
    required SamuraiBoard board,
    required SamuraiBoard initialBoard,
    required SamuraiBoard solution,
    required Difficulty difficulty,
    this.currentSubGridIndex = 4,
    List<bool>? subGridCompletionStatus,
    this.highlightOverlapRegions = false,
    this.isOverviewMode = false,
    super.mistakes = 0,
    super.elapsedTime = 0,
    super.isCompleted = false,
    List<Board>? history,
    super.historyIndex = 0,
    super.startTime,
    super.completionTime,
    super.isShowingSolution = false,
    super.isMarkMode = false,
    super.isAutoMarkMode = false,
    super.hintsUsed = 0,
  }) : subGridCompletionStatus = subGridCompletionStatus ?? List<bool>.filled(5, false),
       super(
         board: board,
         initialBoard: initialBoard,
         solution: solution,
         difficulty: difficulty.name,
         history: history ?? [initialBoard],
       );

  factory SamuraiGameState.fromJson(Map<String, dynamic> json) {
    DateTime? startTime;
    if (json['startTime'] != null) {
      try {
        startTime = DateTime.parse(json['startTime']);
      } catch (e) {
        // 如果解析失败，不设置开始时间
      }
    }
    
    DateTime? completionTime;
    if (json['completionTime'] != null) {
      try {
        completionTime = DateTime.parse(json['completionTime']);
      } catch (e) {
        // 如果解析失败，不设置完成时间
      }
    }
    
    // 解析历史记录
    List<Board> history = [];
    int historyIndex = 0;
    if (json['history'] != null) {
      history = (json['history'] as List)
          .map((b) => SamuraiBoard.fromJson(b))
          .toList();
      historyIndex = json['historyIndex'] ?? history.length - 1;
      if (historyIndex >= history.length) {
        historyIndex = history.isNotEmpty ? history.length - 1 : 0;
      }
    } else {
      // 兼容旧数据：如果没有 history，使用 board 作为初始历史
      final board = SamuraiBoard.fromJson(json['board']);
      history = [board];
      historyIndex = 0;
    }
    
    return SamuraiGameState(
      board: SamuraiBoard.fromJson(json['board']),
      initialBoard: SamuraiBoard.fromJson(json['initialBoard'] ?? json['board']),
      solution: SamuraiBoard.fromJson(json['solution']),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      currentSubGridIndex: json['currentSubGridIndex'] ?? 4,
      subGridCompletionStatus: List<bool>.from(
        json['subGridCompletionStatus'] ?? [false, false, false, false, false],
      ),
      highlightOverlapRegions: json['highlightOverlapRegions'] ?? false,
      isOverviewMode: json['isOverviewMode'] ?? false,
      mistakes: json['mistakes'] ?? 0,
      elapsedTime: json['elapsedTime'] ?? json['timeElapsed'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      history: history,
      historyIndex: historyIndex,
      startTime: startTime,
      completionTime: completionTime,
      isShowingSolution: json['isShowingSolution'] ?? json['showSolution'] ?? false,
      isMarkMode: json['isMarkMode'] ?? false,
      isAutoMarkMode: json['isAutoMarkMode'] ?? false,
      hintsUsed: json['hintsUsed'] ?? 0,
    );
  }
  /// 当前聚焦的子数独索引 (0-4)
  final int currentSubGridIndex;

  /// 子数独完成状态
  final List<bool> subGridCompletionStatus;

  /// 是否高亮重叠区域
  final bool highlightOverlapRegions;

  /// 是否处于概览模式
  final bool isOverviewMode;

  @override
  SamuraiBoard get board => super.board as SamuraiBoard;

  @override
  SamuraiBoard get initialBoard => super.initialBoard as SamuraiBoard;

  @override
  SamuraiBoard get solution => super.solution as SamuraiBoard;

  /// 使用标准的 copyWith 方法，与基类保持一致
  @override
  SamuraiGameState copyWith({
    Board? board,
    Board? initialBoard,
    Board? solution,
    String? difficulty,
    int? mistakes,
    int? elapsedTime,
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
    int? currentSubGridIndex,
    List<bool>? subGridCompletionStatus,
    bool? highlightOverlapRegions,
    bool? isOverviewMode,
  }) => SamuraiGameState(
      board: (board ?? this.board) as SamuraiBoard,
      initialBoard: (initialBoard ?? this.initialBoard) as SamuraiBoard,
      solution: (solution ?? this.solution) as SamuraiBoard,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == (difficulty ?? this.difficulty),
        orElse: () => Difficulty.medium,
      ),
      currentSubGridIndex: currentSubGridIndex ?? this.currentSubGridIndex,
      subGridCompletionStatus: subGridCompletionStatus ?? this.subGridCompletionStatus,
      highlightOverlapRegions: highlightOverlapRegions ?? this.highlightOverlapRegions,
      isOverviewMode: isOverviewMode ?? this.isOverviewMode,
      mistakes: mistakes ?? this.mistakes,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isCompleted: isCompleted ?? this.isCompleted,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      isShowingSolution: isShowingSolution ?? this.isShowingSolution,
      isMarkMode: isMarkMode ?? this.isMarkMode,
      isAutoMarkMode: isAutoMarkMode ?? this.isAutoMarkMode,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );

  @override
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
  }) => SamuraiGameState(
      board: board as SamuraiBoard,
      initialBoard: initialBoard as SamuraiBoard,
      solution: solution as SamuraiBoard,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == difficulty,
        orElse: () => Difficulty.medium,
      ),
      currentSubGridIndex: currentSubGridIndex,
      subGridCompletionStatus: subGridCompletionStatus,
      highlightOverlapRegions: highlightOverlapRegions,
      isOverviewMode: isOverviewMode,
      mistakes: mistakes,
      elapsedTime: elapsedTime,
      isCompleted: isCompleted,
      history: history,
      historyIndex: historyIndex,
      startTime: startTime,
      completionTime: completionTime,
      isShowingSolution: isShowingSolution,
      isMarkMode: isMarkMode,
      isAutoMarkMode: isAutoMarkMode,
      hintsUsed: hintsUsed,
    );

  /// 重置游戏状态
  @override
  GameState resetGame() => copyWith(
      board: initialBoard,
      elapsedTime: 0,
      mistakes: 0,
      isCompleted: false,
      history: [initialBoard],
      historyIndex: 0,
      currentSubGridIndex: 4,
      subGridCompletionStatus: List<bool>.filled(5, false),
      highlightOverlapRegions: false,
      isOverviewMode: false,
      startTime: DateTime.now(),
      isShowingSolution: false,
      isMarkMode: false,
      isAutoMarkMode: false,
    );

  /// 切换子网格
  SamuraiGameState switchSubGrid(int newSubGridIndex) {
    if (newSubGridIndex < 0 || newSubGridIndex >= 5) {
      return this;
    }
    return copyWith(currentSubGridIndex: newSubGridIndex);
  }

  /// 切换概览模式
  SamuraiGameState toggleOverviewMode() => copyWith(isOverviewMode: !isOverviewMode);

  /// 切换重叠区域高亮
  SamuraiGameState toggleOverlapHighlight() => copyWith(highlightOverlapRegions: !highlightOverlapRegions);

  /// 检查子数独是否完成
  bool isSubGridComplete(int subGridIndex) {
    if (subGridIndex < 0 || subGridIndex >= subGridCompletionStatus.length) {
      return false;
    }
    return subGridCompletionStatus[subGridIndex];
  }

  /// 检查所有子数独是否完成
  bool isAllSubGridsComplete() => subGridCompletionStatus.every((status) => status);

  /// 更新子数独完成状态
  SamuraiGameState updateSubGridCompletionStatus() {
    final newStatus = List<bool>.filled(5, false);

    for (int i = 0; i < 5; i++) {
      final (startRow, startCol) = SamuraiBoard.subGridOffsets[i];
      bool isComplete = true;

      for (int row = 0; row < SamuraiBoard.subGridSize; row++) {
        for (int col = 0; col < SamuraiBoard.subGridSize; col++) {
          final targetRow = startRow + row;
          final targetCol = startCol + col;
          if (targetRow >= 0 && targetRow < SamuraiBoard.boardSize &&
              targetCol >= 0 && targetCol < SamuraiBoard.boardSize) {
            final cell = board.getCell(targetRow, targetCol);
            if (cell.value == null) {
              isComplete = false;
              break;
            }
          }
        }
        if (!isComplete) break;
      }

      newStatus[i] = isComplete;
    }

    return copyWith(subGridCompletionStatus: newStatus);
  }

  /// 获取指定子网格的数字使用次数
  Map<int, int> getSubGridNumberCounts(int subGridIndex) {
    final counts = <int, int>{for (var i = 1; i <= 9; i++) i: 0};
    
    final subGridOffset = SamuraiBoard.subGridOffsets[subGridIndex];
    final (startRow, startCol) = subGridOffset;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final actualRow = startRow + row;
        final actualCol = startCol + col;
        final cell = board.getCell(actualRow, actualCol);
        if (cell.value != null && cell.value! >= 1 && cell.value! <= 9) {
          counts[cell.value!] = (counts[cell.value!] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  /// 获取游戏完成百分比（基于可玩单元格）
  @override
  double get completionPercentage {
    final totalCells = board.playableCellCount;
    if (totalCells == 0) return 0.0;
    final filledCells = board.getFilledCells().length;
    return filledCells / totalCells;
  }

  @override
  Map<String, dynamic> toJson() => {
      ...super.toJson(),
      'currentSubGridIndex': currentSubGridIndex,
      'subGridCompletionStatus': subGridCompletionStatus,
      'highlightOverlapRegions': highlightOverlapRegions,
      'isOverviewMode': isOverviewMode,
    };
}
