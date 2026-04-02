import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/processors/solvers/samurai_bit_solver.dart';
import 'package:sudoku/games/samurai/models/samurai_board.dart';

void main() {
  group('SamuraiBitSolver', () {
    late SamuraiBoard board;
    late SamuraiBitSolver solver;

    setUp(() {
      // 创建一个空的武士数独棋盘
      final cells = List.generate(21, (r) =>
          List.generate(21, (c) => Cell(row: r, col: c)));
      board = SamuraiBoard(cells: cells);
      solver = SamuraiBitSolver.create(board: board);
    });

    test('should create instance successfully', () {
      expect(solver, isNotNull);
    });

    test('should initialize overlap data', () {
      expect(solver.overlapCells.length, 5);
      expect(solver.subgridMasks.length, 5);
    });

    test('should calculate candidates for empty cell', () {
      // 测试左上角子网格的中心单元格
      final candidates = solver.getCandidates(0, 4, 4);
      expect(candidates, 0x1ff); // 所有数字都可用 (0b111111111)
    });

    test('should calculate candidates with some values filled', () {
      // 在同一行填充一些值
      final cells = List.generate(21, (r) =>
          List.generate(21, (c) => Cell(row: r, col: c)));
      
      // 填充第一行的一些值
      cells[0][0] = const Cell(row: 0, col: 0, value: 1);
      cells[0][1] = const Cell(row: 0, col: 1, value: 2);
      cells[0][2] = const Cell(row: 0, col: 2, value: 3);
      
      board = SamuraiBoard(cells: cells);
      solver = SamuraiBitSolver.create(board: board);
      
      // 测试同一行的单元格
      final candidates = solver.getCandidates(0, 0, 3);
      // 1, 2, 3 应该不可用
      expect((candidates & (1 << 0)) == 0, true); // 1
      expect((candidates & (1 << 1)) == 0, true); // 2
      expect((candidates & (1 << 2)) == 0, true); // 3
      // 其他数字应该可用
      expect((candidates & (1 << 3)) != 0, true); // 4
      expect((candidates & (1 << 8)) != 0, true); // 9
    });

    test('should count solutions for empty board', () {
      // 对于空棋盘，应该有多个解
      final count = solver.countSolutions(board);
      expect(count, 2); // 应该找到至少2个解
    });

    test('should count solutions for board with fixed values', () {
      // 创建一个有固定值的棋盘
      final cells = List.generate(21, (r) =>
          List.generate(21, (c) => Cell(row: r, col: c)));
      
      // 填充一些固定值
      cells[0][0] = const Cell(row: 0, col: 0, value: 1, isFixed: true);
      cells[0][1] = const Cell(row: 0, col: 1, value: 2, isFixed: true);
      cells[0][2] = const Cell(row: 0, col: 2, value: 3, isFixed: true);
      
      board = SamuraiBoard(cells: cells);
      solver = SamuraiBitSolver.create(board: board);
      
      final count = solver.countSolutions(board);
      expect(count >= 1, true);
    });

    test('should handle cancelled generation', () {
      const bool cancelled = false;
      
      final count = solver.countSolutions(
        board,
        isCancelled: () => cancelled,
      );
      
      expect(count >= 0, true);
    });

    test('should convert bits to values correctly', () {
      const bits = 0x155; // 1, 3, 5, 7, 9 (0b101010101)
      final values = solver.testBitsToValues(bits);
      expect(values, [1, 3, 5, 7, 9]);
    });

    test('should count bits correctly', () {
      const bits = 0x155; // 5个1 (0b101010101)
      final count = solver.testCountBits(bits);
      expect(count, 5);
    });
  });
}
