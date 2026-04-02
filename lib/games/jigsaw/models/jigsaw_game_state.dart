import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/jigsaw/models/jigsaw_board.dart';

class JigsawGameState extends GameState {

  JigsawGameState({
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
  }) : assert(board is JigsawBoard, 'Board must be JigsawBoard'),
       assert(initialBoard is JigsawBoard, 'Initial board must be JigsawBoard'),
       assert(solution is JigsawBoard, 'Solution must be JigsawBoard');

  factory JigsawGameState.fromJson(Map<String, dynamic> json) {
    final common = GameState.parseCommonJsonFields(json);
    final boardJson = json['board'] as Map<String, dynamic>;
    final regionMatrixJson = boardJson['regionMatrix'] as List<dynamic>?;
    final regionMatrix = regionMatrixJson?.map((row) => 
      (row as List).map((cell) => cell as int).toList()
    ).toList() ?? List.generate(9, (_) => List.filled(9, 0));
    
    final historyJson = json['history'] as List? ?? [];
    
    return JigsawGameState(
      board: JigsawBoard.fromJson(boardJson, regionMatrix: regionMatrix),
      initialBoard: JigsawBoard.fromJson(
        json['initialBoard'] as Map<String, dynamic>, 
        regionMatrix: regionMatrix,
      ),
      solution: JigsawBoard.fromJson(
        json['solution'] as Map<String, dynamic>, 
        regionMatrix: regionMatrix,
      ),
      difficulty: common['difficulty'],
      elapsedTime: common['elapsedTime'],
      mistakes: common['mistakes'],
      isCompleted: common['isCompleted'],
      history: historyJson.map((b) => JigsawBoard.fromJson(b as Map<String, dynamic>, regionMatrix: regionMatrix)).toList(),
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
  JigsawBoard get jigsawBoard => board as JigsawBoard;

  List<List<int>> get regionMatrix {
    final jigsawBoard = board as JigsawBoard;
    final initialJigsawBoard = initialBoard as JigsawBoard;
    
    return jigsawBoard.regionMatrix ?? 
           initialJigsawBoard.regionMatrix ??
           List.generate(9, (_) => List.filled(9, 0));
  }

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
  }) => JigsawGameState(
      board: board,
      initialBoard: initialBoard as JigsawBoard,
      solution: solution as JigsawBoard,
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

  Difficulty get difficultyEnum => DifficultyExtension.fromIdentifier(difficulty);

  JigsawGameState copyWithDifficulty(final Difficulty newDifficulty) => 
    copyWith(difficulty: newDifficulty.identifier) as JigsawGameState;
}
