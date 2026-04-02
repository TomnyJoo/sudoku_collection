import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/models/difficulty.dart';
import 'package:sudoku/core/models/region.dart';
import 'package:sudoku/core/processors/index.dart';
import 'package:sudoku/games/window/models/window_board.dart';

void main() {
  group('Window Digging Algorithm', () {
    test('should correctly dig window sudoku puzzle', () async {
      // 创建一个完整的窗口数独解
      final solutionCells = [
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

      final cells = List.generate(9, (r) => 
        List.generate(9, (c) => Cell(
          row: r, 
          col: c, 
          value: solutionCells[r][c],
        ))
      );

      final solution = WindowBoard(size: 9, cells: cells);
      
      // 验证解是否有效
      expect(solution.regions.length, equals(22)); // 9行 + 9列 + 9宫 + 4窗口 - 9宫中已包含部分窗口
      
      // 创建挖空算法
      final diggingAlgorithm = SmartSymmetricDiggingAlgorithm(
        dlxSolver: WindowDLXSolver.create(),
      );

      // 生成谜题
      final config = DiggingConfig.fromDifficulty(Difficulty.medium);
      final puzzle = await diggingAlgorithm.generatePuzzle(solution, config, null);

      // 验证谜题
      expect(puzzle.size, equals(9));
      
      // 计算填充的单元格数量
      int filledCount = 0;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (puzzle.getCell(r, c).value != null) {
            filledCount++;
            expect(puzzle.getCell(r, c).isFixed, isTrue, 
              reason: 'Cell ($r, $c) with value should be fixed');
          } else {
            expect(puzzle.getCell(r, c).isFixed, isFalse, 
              reason: 'Cell ($r, $c) without value should not be fixed');
          }
        }
      }

      AppLogger.debug('Filled cells: $filledCount');
      expect(filledCount, lessThan(81), reason: 'Puzzle should have some empty cells');
      expect(filledCount, greaterThanOrEqualTo(config.minFilledCells), 
        reason: 'Puzzle should have at least ${config.minFilledCells} filled cells');
      expect(filledCount, lessThanOrEqualTo(config.maxFilledCells), 
        reason: 'Puzzle should have at most ${config.maxFilledCells} filled cells');
    });

    test('should verify window constraints in puzzle', () async {
      // 创建一个简单的窗口数独解
      final solutionCells = [
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

      final cells = List.generate(9, (r) => 
        List.generate(9, (c) => Cell(
          row: r, 
          col: c, 
          value: solutionCells[r][c],
        ))
      );

      final solution = WindowBoard(size: 9, cells: cells);
      
      // 验证窗口区域
      final windowRegions = solution.regions.where((r) => r.type == RegionType.window).toList();
      expect(windowRegions.length, equals(4), reason: 'Should have 4 window regions');
      
      // 验证每个窗口区域的数字不重复
      for (final region in windowRegions) {
        final values = region.cells.where((c) => c.value != null).map((c) => c.value!).toList();
        expect(values.toSet().length, equals(values.length), 
          reason: 'Window region ${region.id} should not have duplicate values');
      }
    });

    test('should count solutions correctly for window puzzle', () {
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
  });
}
