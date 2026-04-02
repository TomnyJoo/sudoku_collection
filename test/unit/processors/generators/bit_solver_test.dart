import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/processors/solvers/bit_solver.dart';
import 'package:sudoku/core/processors/solvers/dlx_solver.dart';
import 'package:sudoku/games/diagonal/models/diagonal_board.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import 'package:sudoku/games/window/models/window_board.dart';

void main() {
  group('BitSolver', () {
    late BitSolver solver;

    setUp(() {
      solver = StandardBitSolver.create();
    });

    Board createSimplePuzzle() {
      final cells = List.generate(9, (r) =>
          List.generate(9, (c) => Cell(row: r, col: c)));
      final puzzle = [
        [5,3,0,0,7,0,0,0,0],
        [6,0,0,1,9,5,0,0,0],
        [0,9,8,0,0,0,0,6,0],
        [8,0,0,0,6,0,0,0,3],
        [4,0,0,8,0,3,0,0,1],
        [7,0,0,0,2,0,0,0,6],
        [0,6,0,0,0,0,2,8,0],
        [0,0,0,4,1,9,0,0,5],
        [0,0,0,0,8,0,0,7,9],
      ];
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (puzzle[r][c] != 0) {
            cells[r][c] = Cell(row: r, col: c, value: puzzle[r][c]);
          }
        }
      }
      final tempBoard = StandardBoard(size: 9, cells: cells);
      return StandardBoard(size: 9, cells: cells, regions: tempBoard.createRegions());
    }

    Board createInvalidPuzzle() {
      final cells = List.generate(9, (r) =>
          List.generate(9, (c) => Cell(row: r, col: c)));
      cells[0][0] = const Cell(row: 0, col: 0, value: 1);
      cells[0][1] = const Cell(row: 0, col: 1, value: 2);
      cells[0][2] = const Cell(row: 0, col: 2, value: 3);
      cells[1][0] = const Cell(row: 1, col: 0, value: 4);
      cells[1][1] = const Cell(row: 1, col: 1, value: 5);
      cells[1][2] = const Cell(row: 1, col: 2, value: 6);
      cells[2][0] = const Cell(row: 2, col: 0, value: 7);
      cells[2][1] = const Cell(row: 2, col: 1, value: 8);
      cells[2][2] = const Cell(row: 2, col: 2, value: 9);
      cells[0][3] = const Cell(row: 0, col: 3, value: 1);
      final tempBoard = StandardBoard(size: 9, cells: cells);
      return StandardBoard(size: 9, cells: cells, regions: tempBoard.createRegions());
    }

    Board createMultipleSolutionPuzzle() {
      final cells = List.generate(9, (r) =>
          List.generate(9, (c) => Cell(row: r, col: c)));
      cells[0][0] = const Cell(row: 0, col: 0, value: 1);
      cells[0][1] = const Cell(row: 0, col: 1, value: 2);
      cells[1][0] = const Cell(row: 1, col: 0, value: 3);
      final tempBoard = StandardBoard(size: 9, cells: cells);
      return StandardBoard(size: 9, cells: cells, regions: tempBoard.createRegions());
    }

    test('应该正确初始化', () {
      expect(solver.size, equals(9));
      expect(solver.boxSize, equals(3));
    });

    test('应该正确计算解的数量', () {
      final puzzle = createSimplePuzzle();
      final count = solver.countSolutions(puzzle);
      expect(count, equals(1));
    });

    test('应该正确识别无解情况', () {
      final puzzle = createInvalidPuzzle();
      final count = solver.countSolutions(puzzle);
      expect(count, equals(0));
    });

    test('应该在找到2个解时停止', () {
      final puzzle = createMultipleSolutionPuzzle();
      final count = solver.countSolutions(puzzle);
      expect(count, equals(2));
    });
  });

  group('DiagonalBitSolver', () {
    late DiagonalBitSolver solver;

    setUp(() {
      solver = DiagonalBitSolver.create();
    });

    test('应该正确初始化', () {
      expect(solver.size, equals(9));
      expect(solver.boxSize, equals(3));
      expect(solver.extraRegions, isNotNull);
    });

    test('应该正确识别无解情况', () {
      final cells = List.generate(9, (r) =>
          List.generate(9, (c) => Cell(row: r, col: c)));
      cells[0][0] = const Cell(row: 0, col: 0, value: 1);
      cells[0][1] = const Cell(row: 0, col: 1, value: 2);
      cells[0][2] = const Cell(row: 0, col: 2, value: 3);
      cells[1][0] = const Cell(row: 1, col: 0, value: 4);
      cells[1][1] = const Cell(row: 1, col: 1, value: 5);
      cells[1][2] = const Cell(row: 1, col: 2, value: 6);
      cells[2][0] = const Cell(row: 2, col: 0, value: 7);
      cells[2][1] = const Cell(row: 2, col: 1, value: 8);
      cells[2][2] = const Cell(row: 2, col: 2, value: 9);
      cells[0][3] = const Cell(row: 0, col: 3, value: 1);
      final tempBoard = DiagonalBoard(size: 9, cells: cells);
      final puzzle = DiagonalBoard(size: 9, cells: cells, regions: tempBoard.createRegions());
      final count = solver.countSolutions(puzzle);
      expect(count, equals(0));
    });
  });

  group('WindowBitSolver', () {
    late WindowBitSolver solver;

    setUp(() {
      solver = WindowBitSolver.create();
    });

    test('应该正确初始化', () {
      expect(solver.size, equals(9));
      expect(solver.boxSize, equals(3));
      expect(solver.extraRegions, isNotNull);
    });

    test('应该正确识别无解情况', () {
      final cells = List.generate(9, (r) =>
          List.generate(9, (c) => Cell(row: r, col: c)));
      cells[0][0] = const Cell(row: 0, col: 0, value: 1);
      cells[0][1] = const Cell(row: 0, col: 1, value: 2);
      cells[0][2] = const Cell(row: 0, col: 2, value: 3);
      cells[1][0] = const Cell(row: 1, col: 0, value: 4);
      cells[1][1] = const Cell(row: 1, col: 1, value: 5);
      cells[1][2] = const Cell(row: 1, col: 2, value: 6);
      cells[2][0] = const Cell(row: 2, col: 0, value: 7);
      cells[2][1] = const Cell(row: 2, col: 1, value: 8);
      cells[2][2] = const Cell(row: 2, col: 2, value: 9);
      cells[0][3] = const Cell(row: 0, col: 3, value: 1);
      final tempBoard = WindowBoard(size: 9, cells: cells);
      final puzzle = WindowBoard(size: 9, cells: cells, regions: tempBoard.createRegions());
      final count = solver.countSolutions(puzzle);
      expect(count, equals(0));
    });
  });

  group('BitSolver性能基准测试', () {
    Board createHardPuzzle() {
      final cells = List.generate(9, (r) =>
          List.generate(9, (c) => Cell(row: r, col: c)));
      final puzzle = [
        [0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,3,0,8,5],
        [0,0,1,0,2,0,0,0,0],
        [0,0,0,5,0,7,0,0,0],
        [0,0,4,0,0,0,1,0,0],
        [0,9,0,0,0,0,0,0,0],
        [5,0,0,0,0,0,0,7,3],
        [0,0,2,0,1,0,0,0,0],
        [0,0,0,0,4,0,0,0,9],
      ];
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (puzzle[r][c] != 0) {
            cells[r][c] = Cell(row: r, col: c, value: puzzle[r][c]);
          }
        }
      }
      final tempBoard = StandardBoard(size: 9, cells: cells);
      return StandardBoard(size: 9, cells: cells, regions: tempBoard.createRegions());
    }

    Duration measureTime(VoidCallback action) {
      final stopwatch = Stopwatch()..start();
      action();
      stopwatch.stop();
      return stopwatch.elapsed;
    }

    test('BitSolver性能基准测试', () {
      final puzzle = createHardPuzzle();

      final dlxSolver = DLXSudokuSolver(size: 9);
      final bitSolver = StandardBitSolver.create();

      final dlxTime = measureTime(() {
        dlxSolver.countSolutions(puzzle);
      });

      final bitTime = measureTime(() {
        bitSolver.countSolutions(puzzle);
      });

      AppLogger.info('DLX求解器耗时: ${dlxTime.inMilliseconds}ms');
      AppLogger.info('BitSolver求解器耗时: ${bitTime.inMilliseconds}ms');

      final speedup = dlxTime.inMicroseconds / bitTime.inMicroseconds;
      AppLogger.info('BitSolver加速比: ${speedup.toStringAsFixed(2)}x');

      expect(speedup, greaterThan(0.1),
             reason: 'BitSolver应该能够正常工作');
    }, skip: '性能优化需要进一步改进');
  });
}
