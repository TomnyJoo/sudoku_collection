import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/window/models/window_board.dart';

class WindowGameState extends GameState {
  WindowGameState({
    required super.board,
    required super.initialBoard,
    required super.solution,
    required super.difficulty,
    super.elapsedTime,
    super.mistakes,
    super.isCompleted,
    super.history,
    super.historyIndex,
    super.numberCounts,
    super.startTime,
    super.completionTime,
    super.isShowingSolution,
    super.isMarkMode,
    super.isAutoMarkMode,
    super.hintsUsed,
  }) : assert(board is WindowBoard, 'Board must be WindowBoard'),
       assert(initialBoard is WindowBoard, 'Initial board must be WindowBoard'),
       assert(solution is WindowBoard, 'Solution must be WindowBoard');

  factory WindowGameState.fromJson(Map<String, dynamic> json) {
    final common = GameState.parseCommonJsonFields(json);
    final historyJson = json['history'] as List? ?? [];
    
    return WindowGameState(
      board: WindowBoard.fromJson(json['board'] as Map<String, dynamic>),
      initialBoard: WindowBoard.fromJson(json['initialBoard'] as Map<String, dynamic>),
      solution: WindowBoard.fromJson(json['solution'] as Map<String, dynamic>),
      difficulty: common['difficulty'],
      elapsedTime: common['elapsedTime'],
      mistakes: common['mistakes'],
      isCompleted: common['isCompleted'],
      history: historyJson.map((b) => WindowBoard.fromJson(b as Map<String, dynamic>)).toList(),
      historyIndex: common['historyIndex'],
      numberCounts: common['numberCounts'],
      startTime: common['startTime'],
      completionTime: common['completionTime'],
      isShowingSolution: common['isShowingSolution'],
      isMarkMode: common['isMarkMode'],
      isAutoMarkMode: common['isAutoMarkMode'],
      hintsUsed: common['hintsUsed'],
    );
  }

  /// 获取类型化的棋盘
  WindowBoard get windowBoard => board as WindowBoard;

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
  }) => WindowGameState(
      board: board as WindowBoard,
      initialBoard: initialBoard as WindowBoard,
      solution: solution as WindowBoard,
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
}
