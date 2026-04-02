import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/models/board.dart';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/models/difficulty.dart';
import 'package:sudoku/core/processors/solvers/dlx_solver.dart';
import 'package:sudoku/games/window/models/window_board.dart';
import 'package:sudoku/games/window/window_constants.dart';
import 'package:sudoku/games/window/window_generator.dart';

void main() {
  group('DLX Solver Debug Test', () {
    test('should verify DLX solver window constraints', () {
      final solver = WindowDLXSolver.create();
      
      AppLogger.debug('DLX Solver size: ${solver.size}');
      AppLogger.debug('DLX Solver extraRegions count: ${solver.extraRegions?.length ?? 0}');
      
      // 验证 extraRegions 不为空
      expect(solver.extraRegions, isNotNull);
      expect(solver.extraRegions!.length, equals(4));
      
      // 验证每个窗口区域的大小
      for (int i = 0; i < 4; i++) {
        final window = solver.extraRegions![i];
        int cellCount = 0;
        for (int j = 0; j < 81; j++) {
          if (window[j] == 1) cellCount++;
        }
        AppLogger.debug('Window $i has $cellCount cells');
        expect(cellCount, equals(9), reason: 'Window $i should have 9 cells');
      }
    });

    test('should count solutions for generated window sudoku', () async {
      final solver = WindowDLXSolver.create();
      
      // 使用 WindowGenerator 生成一个有效的窗口数独解
      final generator = WindowGenerator();
      final result = await generator.generate(
        difficulty: Difficulty.medium,
        size: 9,
      );

      final solution = result.solution;
      
      // 验证窗口约束
      for (final windowRegion in WindowConstants.windowRegions) {
        final values = <int>{};
        final duplicates = <int>[];
        
        for (int r = windowRegion.startRow - 1; r <= windowRegion.endRow - 1; r++) {
          for (int c = windowRegion.startCol - 1; c <= windowRegion.endCol - 1; c++) {
            final val = solution.getCell(r, c).value!;
            if (values.contains(val)) {
              duplicates.add(val);
            }
            values.add(val);
          }
        }
        
        AppLogger.debug('Window ${windowRegion.id}: values = $values, duplicates = $duplicates');
        expect(duplicates.isEmpty, isTrue, 
          reason: 'Window ${windowRegion.id} should not have duplicate values');
      }
      
      // 计算解的数量
      final count = solver.countSolutions(solution);
      AppLogger.debug('Generated solution count: $count');
      
      // 完整的解应该只有 1 个解
      expect(count, equals(1));
    });

    test('should count solutions for partial window sudoku', () {
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
      AppLogger.debug('Partial puzzle solution count: $count');
      
      // 应该有多个解（因为只填了3个数字）
      expect(count, greaterThanOrEqualTo(1));
    });

    test('should verify digging algorithm DLX solver with generated puzzle', () async {
      final dlxSolver = WindowDLXSolver.create();
      
      // 使用 WindowGenerator 生成一个有效的窗口数独解
      final generator = WindowGenerator();
      final result = await generator.generate(
        difficulty: Difficulty.medium,
        size: 9,
      );

      final solution = result.solution;
      final puzzle = result.puzzle;

      AppLogger.debug('Puzzle filled cells: ${_countFilledCells(puzzle)}');
      AppLogger.debug('Solution filled cells: ${_countFilledCells(solution)}');

      // 计算解的数量
      final count = dlxSolver.countSolutions(puzzle);
      AppLogger.debug('Generated puzzle solution count: $count');
      
      // 应该只有 1 个解
      expect(count, equals(1));
    });
  });
}

int _countFilledCells(Board board) {
  int cnt = 0;
  for (int r = 0; r < board.size; r++) {
    for (int c = 0; c < board.size; c++) {
      if (board.getCell(r, c).value != null) cnt++;
    }
  }
  return cnt;
}
