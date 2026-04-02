import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/processors/solvers/dlx_solver.dart';
import 'package:sudoku/games/window/models/window_board.dart';
import 'package:sudoku/games/window/window_constants.dart';

void main() {
  group('WindowDLXSolver', () {
    test('should correctly create window constraints', () {
      final solver = WindowDLXSolver.create();
      
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
        expect(cellCount, equals(9), reason: 'Window $i should have 9 cells');
      }
      
      // 验证窗口位置
      // 左上窗口：行 0-2，列 0-2
      final topLeftWindow = solver.extraRegions![0];
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          expect(topLeftWindow[r * 9 + c], equals(1), 
            reason: 'Cell ($r, $c) should be in top-left window');
        }
      }
      
      // 右上窗口：行 0-2，列 4-6
      final topRightWindow = solver.extraRegions![1];
      for (int r = 0; r < 3; r++) {
        for (int c = 4; c < 7; c++) {
          expect(topRightWindow[r * 9 + c], equals(1), 
            reason: 'Cell ($r, $c) should be in top-right window');
        }
      }
      
      // 左下窗口：行 4-6，列 0-2
      final bottomLeftWindow = solver.extraRegions![2];
      for (int r = 4; r < 7; r++) {
        for (int c = 0; c < 3; c++) {
          expect(bottomLeftWindow[r * 9 + c], equals(1), 
            reason: 'Cell ($r, $c) should be in bottom-left window');
        }
      }
      
      // 右下窗口：行 4-6，列 4-6
      final bottomRightWindow = solver.extraRegions![3];
      for (int r = 4; r < 7; r++) {
        for (int c = 4; c < 7; c++) {
          expect(bottomRightWindow[r * 9 + c], equals(1), 
            reason: 'Cell ($r, $c) should be in bottom-right window');
        }
      }
    });

    test('should match WindowConstants.windowRegions', () {
      final solver = WindowDLXSolver.create();
      
      for (int i = 0; i < 4; i++) {
        final windowRegion = WindowConstants.windowRegions[i];
        final solverWindow = solver.extraRegions![i];
        
        // 验证窗口区域与 WindowConstants 一致
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            final inWindowRegion = r >= windowRegion.startRow - 1 && 
                                   r <= windowRegion.endRow - 1 &&
                                   c >= windowRegion.startCol - 1 && 
                                   c <= windowRegion.endCol - 1;
            final inSolverWindow = solverWindow[r * 9 + c] == 1;
            
            expect(inSolverWindow, equals(inWindowRegion), 
              reason: 'Window $i: Cell ($r, $c) mismatch');
          }
        }
      }
    });

    test('should count solutions correctly for window sudoku', () {
      final solver = WindowDLXSolver.create();
      
      // 创建一个简单的窗口数独谜题
      // 使用一个已知的窗口数独谜题
      final cells = List.generate(9, (r) => 
        List.generate(9, (c) {
          // 简单的测试：部分填充
          if (r == 0 && c == 0) return Cell(row: r, col: c, value: 1);
          if (r == 0 && c == 1) return Cell(row: r, col: c, value: 2);
          if (r == 1 && c == 0) return Cell(row: r, col: c, value: 3);
          return Cell(row: r, col: c);
        })
      );
      
      final board = WindowBoard(size: 9, cells: cells);
      
      // 计算解的数量
      final solutionCount = solver.countSolutions(board);

      // 应该有多个解（因为只填了3个数字）
      expect(solutionCount, greaterThanOrEqualTo(1));
    });
  });
}
