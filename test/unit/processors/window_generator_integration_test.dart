import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/models/difficulty.dart';
import 'package:sudoku/core/processors/solvers/dlx_solver.dart';
import 'package:sudoku/games/window/models/window_board.dart';
import 'package:sudoku/games/window/window_generator.dart';

void main() {
  group('WindowGenerator Integration Test', () {
    test('should generate valid window sudoku puzzle', () async {
      final generator = WindowGenerator();
      
      final result = await generator.generate(
        difficulty: Difficulty.medium,
        size: 9,
      );

      // 验证结果
      expect(result.puzzle, isNotNull);
      expect(result.solution, isNotNull);
      expect(result.puzzle.size, equals(9));
      expect(result.solution.size, equals(9));

      // 计算填充的单元格数量
      int puzzleFilledCount = 0;
      int solutionFilledCount = 0;
      int puzzleFixedCount = 0;
      int solutionFixedCount = 0;

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final pCell = result.puzzle.getCell(r, c);
          final sCell = result.solution.getCell(r, c);

          if (pCell.value != null) {
            puzzleFilledCount++;
            if (pCell.isFixed) puzzleFixedCount++;
          }

          if (sCell.value != null) {
            solutionFilledCount++;
            if (sCell.isFixed) solutionFixedCount++;
          }
        }
      }

      AppLogger.debug('Puzzle filled cells: $puzzleFilledCount');
      AppLogger.debug('Puzzle fixed cells: $puzzleFixedCount');
      AppLogger.debug('Solution filled cells: $solutionFilledCount');
      AppLogger.debug('Solution fixed cells: $solutionFixedCount');

      // 验证谜题有挖空
      expect(puzzleFilledCount, lessThan(81), 
        reason: 'Puzzle should have some empty cells');

      // 验证谜题的固定单元格数量等于填充单元格数量
      expect(puzzleFixedCount, equals(puzzleFilledCount), 
        reason: 'All filled cells in puzzle should be fixed');

      // 验证解是完整的
      expect(solutionFilledCount, equals(81), 
        reason: 'Solution should be complete');

      // 验证解的固定单元格数量等于谜题的填充单元格数量
      expect(solutionFixedCount, equals(puzzleFilledCount), 
        reason: 'Solution fixed cells should match puzzle filled cells');
    });

    test('should verify DLX solver is correctly configured', () {
      final solver = WindowDLXSolver.create();
      
      // 创建一个部分填充的窗口数独
      final cells = List.generate(9, (r) => 
        List.generate(9, (c) => Cell(row: r, col: c))
      );
      
      // 填入一些数字
      cells[0][0] = const Cell(row: 0, col: 0, value: 5);
      cells[0][1] = const Cell(row: 0, col: 1, value: 3);
      cells[1][0] = const Cell(row: 1, col: 0, value: 6);
      
      final puzzle = WindowBoard(size: 9, cells: cells);
      
      // 计算解的数量
      final count = solver.countSolutions(puzzle);
      AppLogger.debug('Solution count: $count');
      
      // 应该有多个解（因为只填了3个数字）
      expect(count, greaterThanOrEqualTo(1));
    });

    test('should verify digging algorithm uses correct DLX solver', () {
      final dlxSolver = WindowDLXSolver.create();

      // 验证 DLX 求解器有窗口约束
      expect(dlxSolver.extraRegions, isNotNull);
      expect(dlxSolver.extraRegions!.length, equals(4));
    });
  });
}
