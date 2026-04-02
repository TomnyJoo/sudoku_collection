import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/processors/solvers/jigsaw_bit_solver.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';

void main() {
  group('JigsawBitSolver', () {
    test('应该创建JigsawBitSolver实例', () {
      final regionMatrix = _createStandardRegionMatrix();
      final solver = JigsawBitSolver.create(regionMatrix: regionMatrix);
      expect(solver, isNotNull);
    });

    test('应该正确初始化区域数据', () {
      final regionMatrix = _createStandardRegionMatrix();
      final solver = JigsawBitSolver.create(regionMatrix: regionMatrix);

      // 验证regionCells有9个区域
      expect(solver.regionCells.length, 9);

      // 每个区域应该有9个单元格
      for (int i = 0; i < 9; i++) {
        expect(solver.regionCells[i].length, 9);
      }

      // 验证cellToRegion映射
      expect(solver.cellToRegion[0], 0); // (0,0) -> region 0
      expect(solver.cellToRegion[8], 8); // (8,8) -> region 8
    });

    test('countSolutions应该返回非负数', () {
      final regionMatrix = _createStandardRegionMatrix();
      final solver = JigsawBitSolver.create(regionMatrix: regionMatrix);

      // 创建一个已解决的数独（标准9x9）
      final solvedPuzzle = _createSolvedSudoku();

      // 完整数独应该至少有1个解
      final count = solver.countSolutions(solvedPuzzle);
      expect(count, greaterThanOrEqualTo(1));
    });
  });
}

// 创建一个已解决的标准数独
StandardBoard _createSolvedSudoku() {
  // 创建一个9x9的单元格网格
  final cells = List.generate(9, (r) =>
    List.generate(9, (c) => Cell(row: r, col: c)));

  final board = StandardBoard(size: 9, cells: cells);

  // 填入一个完整的有效数独
  final solution = [
    [5,3,4,6,7,8,9,1,2],
    [6,7,2,1,9,5,3,4,8],
    [1,9,8,3,4,2,5,6,7],
    [8,5,9,7,6,1,4,2,3],
    [4,2,6,8,5,3,7,9,1],
    [7,1,3,9,2,4,8,5,6],
    [9,6,1,5,3,7,2,8,4],
    [2,8,7,4,1,9,6,3,5],
    [3,4,5,2,8,6,1,7,9],
  ];

  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      board.setCellValue(r, c, solution[r][c]);
    }
  }
  return board;
}

// 创建标准区域矩阵（3x3宫格）
List<List<int>> _createStandardRegionMatrix() {
  final matrix = List.generate(9, (_) => List.filled(9, 0));
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      matrix[r][c] = (r ~/ 3) * 3 + (c ~/ 3);
    }
  }
  return matrix;
}

Matcher get isNonZero => isNot(equals(0));
Matcher get isZero => equals(0);
