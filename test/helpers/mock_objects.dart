import 'package:sudoku/core/index.dart';

class MockObjects {
  static Cell createCell({
    int row = 0,
    int col = 0,
    int? value,
    bool isFixed = false,
    bool isError = false,
    final Set<int>? candidates,
  }) =>
      Cell(
        row: row,
        col: col,
        value: value,
        isFixed: isFixed,
        isError: isError,
        candidates: candidates,
      );

  static List<List<Cell>> createEmptyCells(int size) => List.generate(
        size,
        (row) => List.generate(
          size,
          (col) => Cell(row: row, col: col),
        ),
      );

  static List<List<Cell>> createFilledCells(List<List<int?>> values) =>
      List.generate(
        values.length,
        (row) => List.generate(
          values[row].length,
          (col) => Cell(
            row: row,
            col: col,
            value: values[row][col],
            isFixed: values[row][col] != null,
          ),
        ),
      );

  static List<List<int?>> createValidSudoku() => const [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ];
}
