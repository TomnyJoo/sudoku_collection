import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/diagonal/models/diagonal_board.dart';

class DiagonalGameState extends GameState {
  DiagonalGameState({
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
  }) : assert(board is DiagonalBoard, 'Board must be DiagonalBoard'),
       assert(initialBoard is DiagonalBoard, 'Initial board must be DiagonalBoard'),
       assert(solution is DiagonalBoard, 'Solution must be DiagonalBoard');

  factory DiagonalGameState.fromJson(Map<String, dynamic> json) {
    final common = GameState.parseCommonJsonFields(json);
    final historyJson = json['history'] as List? ?? [];
    
    return DiagonalGameState(
      board: DiagonalBoard.fromJson(json['board'] as Map<String, dynamic>),
      initialBoard: DiagonalBoard.fromJson(json['initialBoard'] as Map<String, dynamic>),
      solution: DiagonalBoard.fromJson(json['solution'] as Map<String, dynamic>),
      difficulty: common['difficulty'],
      elapsedTime: common['elapsedTime'],
      mistakes: common['mistakes'],
      isCompleted: common['isCompleted'],
      history: historyJson.map((b) => DiagonalBoard.fromJson(b as Map<String, dynamic>)).toList(),
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
  DiagonalBoard get diagonalBoard => board as DiagonalBoard;

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
  }) => DiagonalGameState(
      board: board as DiagonalBoard,
      initialBoard: initialBoard as DiagonalBoard,
      solution: solution as DiagonalBoard,
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
