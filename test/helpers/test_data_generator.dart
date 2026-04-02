import 'dart:math';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/killer/models/killer_board.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import 'package:sudoku/games/window/models/window_board.dart';

class TestDataGenerator {
  static StandardBoard generateStandardBoard(Difficulty difficulty) {
    // 生成标准数独棋盘
    final cells = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => Cell(row: row, col: col),
      ),
    );
    return StandardBoard(size: 9, cells: cells);
  }

  static KillerBoard generateKillerBoard(Difficulty difficulty) {
    // 生成杀手数独棋盘
    final cells = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => Cell(row: row, col: col),
      ),
    );
    return KillerBoard(size: 9, cells: cells, cages: []);
  }

  static WindowBoard generateWindowBoard(Difficulty difficulty) {
    // 生成窗口数独棋盘
    final cells = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => Cell(row: row, col: col),
      ),
    );
    return WindowBoard(size: 9, cells: cells);
  }

  static GameState createGameState(
    Board board,
    Board solution,
    Difficulty difficulty,
  ) => GameState(
      board: board,
      initialBoard: board,
      solution: solution,
      startTime: DateTime.now(),
      difficulty: difficulty.name,
    );

  static List<List<Cell>> generateTestBoard(int size, double filledCells) {
    final cells = List.generate(
      size,
      (row) => List.generate(
        size,
        (col) {
          final isFilled = Random().nextDouble() < filledCells;
          return Cell(
            row: row,
            col: col,
            value: isFilled ? Random().nextInt(9) + 1 : null,
            isFixed: isFilled,
          );
        },
      ),
    );
    return cells;
  }
}
