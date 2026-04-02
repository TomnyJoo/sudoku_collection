import 'dart:math';
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/processors/solvers/bit_solver.dart';
import 'package:sudoku/games/samurai/models/samurai_board.dart';

/// 武士数独专用BitSolver
class SamuraiBitSolver extends BitSolver {
  SamuraiBitSolver({required this.board, super.random}) : super(size: 9) {
    _initOverlapData();
  }

  final SamuraiBoard board;
  late List<List<int>> overlapCells; // 重叠区域的单元格索引
  late List<List<int>> subgridMasks; // 每个子网格的掩码

  /// 初始化重叠数据
  void _initOverlapData() {
    overlapCells = List.generate(5, (_) => <int>[]);
    subgridMasks = List.generate(5, (_) => List.filled(9, 0));

    // 定义五个子网格的区域
    final subgrids = [
      // 左上角子网格 (0,0)
      [
        for (int r = 0; r < 9; r++)
          for (int c = 0; c < 9; c++) r * 15 + c,
      ],
      // 右上角子网格 (0,6)
      [
        for (int r = 0; r < 9; r++)
          for (int c = 6; c < 15; c++) r * 15 + c,
      ],
      // 中心子网格 (6,3)
      [
        for (int r = 6; r < 15; r++)
          for (int c = 3; c < 12; c++) r * 15 + c,
      ],
      // 左下角子网格 (12,0)
      [
        for (int r = 12; r < 21; r++)
          for (int c = 0; c < 9; c++) r * 15 + c,
      ],
      // 右下角子网格 (12,6)
      [
        for (int r = 12; r < 21; r++)
          for (int c = 6; c < 15; c++) r * 15 + c,
      ],
    ];

    for (int sg = 0; sg < 5; sg++) {
      overlapCells[sg] = subgrids[sg];
    }
  }

  /// 计算指定子网格中单元格的候选数
  int getCandidates(int sg, int r, int c) {
    final globalR = _getGlobalRow(sg, r);
    final globalC = _getGlobalCol(sg, c);

    // 计算行、列掩码
    int rowMask = 0;
    int colMask = 0;

    // 计算行掩码
    for (int i = 0; i < 15; i++) {
      final cell = board.getCell(globalR, i);
      if (cell.value != null) {
        rowMask |= 1 << (cell.value! - 1);
      }
    }

    // 计算列掩码
    for (int i = 0; i < 21; i++) {
      final cell = board.getCell(i, globalC);
      if (cell.value != null) {
        colMask |= 1 << (cell.value! - 1);
      }
    }

    // 计算子网格掩码
    int gridMask = 0;
    for (final cellIdx in overlapCells[sg]) {
      final cr = cellIdx ~/ 15;
      final cc = cellIdx % 15;
      final cell = board.getCell(cr, cc);
      if (cell.value != null) {
        gridMask |= 1 << (cell.value! - 1);
      }
    }

    return fullMask & ~(rowMask | colMask | gridMask);
  }

  /// 转换子网格坐标到全局坐标
  int _getGlobalRow(int sg, int r) {
    switch (sg) {
      case 0:
        return r; // 左上角
      case 1:
        return r; // 右上角
      case 2:
        return r + 6; // 中心
      case 3:
        return r + 12; // 左下角
      case 4:
        return r + 12; // 右下角
      default:
        return r;
    }
  }

  int _getGlobalCol(int sg, int c) {
    switch (sg) {
      case 0:
        return c; // 左上角
      case 1:
        return c + 6; // 右上角
      case 2:
        return c + 3; // 中心
      case 3:
        return c; // 左下角
      case 4:
        return c + 6; // 右下角
      default:
        return c;
    }
  }

  /// 计数解的数量
  @override
  int countSolutions(
    Board puzzle, {
    int maxCount = 2,
    bool Function()? isCancelled,
  }) {
    if (puzzle is SamuraiBoard) {
      return _countSolutions(
        puzzle,
        maxCount: maxCount,
        isCancelled: isCancelled,
        count: 0,
      );
    }
    return 0;
  }

  /// 生成解决方案
  SamuraiBoard? generateSolution(bool Function()? isCancelled) {
    // 创建空的武士数独棋盘
    final cells = List.generate(21, (r) =>
      List.generate(15, (c) => Cell(row: r, col: c))
    );
    final board = SamuraiBoard(cells: cells);
    
    // 逐个生成子网格，按中心 -> 左上 -> 右上 -> 左下 -> 右下的顺序
    final subgrids = [2, 0, 1, 3, 4]; // 生成顺序：中心、左上、右上、左下、右下
    
    for (final sg in subgrids) {
      if (isCancelled?.call() ?? false) return null;
      
      if (!_generateSubgrid(board, sg, isCancelled)) {
        return null; // 生成失败
      }
    }
    
    return board;
  }

  /// 生成指定子网格
  bool _generateSubgrid(
    SamuraiBoard board,
    int sg,
    bool Function()? isCancelled,
  ) {
    // 为子网格创建一个临时的矩阵
    final subgridMatrix = List.generate(9, (r) =>
      List.generate(9, (c) {
        final globalR = _getGlobalRow(sg, r);
        final globalC = _getGlobalCol(sg, c);
        final cell = board.getCell(globalR, globalC);
        return cell.value ?? 0;
      })
    );
    
    // 使用标准数独生成器生成子网格
    
    // 生成完整的子网格解
    if (!_generateSubgridSolution(subgridMatrix, isCancelled)) {
      return false;
    }
    
    // 将生成的解复制回武士数独棋盘
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final globalR = _getGlobalRow(sg, r);
        final globalC = _getGlobalCol(sg, c);
        final value = subgridMatrix[r][c];
        if (value != 0) {
          board.setCellValue(globalR, globalC, value);
        }
      }
    }
    
    return true;
  }

  /// 生成子网格的解决方案
  bool _generateSubgridSolution(
    List<List<int>> matrix,
    bool Function()? isCancelled,
  ) {
    // 首先填充固定值的掩码
    final rowMask = List.filled(9, 0);
    final colMask = List.filled(9, 0);
    final boxMask = List.filled(9, 0);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = matrix[r][c];
        if (val != 0) {
          final bit = 1 << (val - 1);
          rowMask[r] |= bit;
          colMask[c] |= bit;
          final boxIdx = (r ~/ 3) * 3 + (c ~/ 3);
          boxMask[boxIdx] |= bit;
        }
      }
    }

    bool found = false;

    void dfs() {
      if (isCancelled?.call() ?? false) return;
      if (found) return;

      // 找到第一个空单元格
      int bestR = -1, bestC = -1, bestBits = 0, minCount = 10;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (matrix[r][c] != 0) continue;
          
          // 计算候选数
          final row = rowMask[r];
          final col = colMask[c];
          final box = boxMask[(r ~/ 3) * 3 + (c ~/ 3)];
          final bits = 0x1ff & ~(row | col | box);
          
          if (bits == 0) return;
          
          final cnt = _countBits(bits);
          if (cnt < minCount) {
            minCount = cnt;
            bestR = r;
            bestC = c;
            bestBits = bits;
            if (cnt == 1) break;
          }
        }
        if (bestR != -1 && minCount == 1) break;
      }

      if (bestR == -1) {
        // 找到解决方案
        found = true;
        return;
      }

      // 尝试所有候选数
      final candidates = _bitsToValues(bestBits)..shuffle(random);
      for (final val in candidates) {
        if (isCancelled?.call() ?? false) return;
        
        final r = bestR;
        final c = bestC;
        final bit = 1 << (val - 1);
        final boxIdx = (r ~/ 3) * 3 + (c ~/ 3);
        
        // 保存状态
        final oldVal = matrix[r][c];
        final oldRowMask = rowMask[r];
        final oldColMask = colMask[c];
        final oldBoxMask = boxMask[boxIdx];
        
        // 设置值
        matrix[r][c] = val;
        rowMask[r] |= bit;
        colMask[c] |= bit;
        boxMask[boxIdx] |= bit;
        
        // 继续搜索
        dfs();
        
        if (found) return;
        
        // 回溯
        matrix[r][c] = oldVal;
        rowMask[r] = oldRowMask;
        colMask[c] = oldColMask;
        boxMask[boxIdx] = oldBoxMask;
      }
    }

    dfs();
    return found;
  }

  /// 递归计数解
  int _countSolutions(
    SamuraiBoard puzzle, {
    required int maxCount,
    required bool Function()? isCancelled,
    required int count,
  }) {
    if (isCancelled?.call() ?? false) return count;
    if (count >= maxCount) return count;

    // 找到第一个空单元格
    for (int sg = 0; sg < 5; sg++) {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final globalR = _getGlobalRow(sg, r);
          final globalC = _getGlobalCol(sg, c);
          final cell = puzzle.getCell(globalR, globalC);

          if (cell.value == null) {
            final candidates = getCandidates(sg, r, c);
            if (candidates == 0) return count; // 死胡同

            // 尝试所有候选数
            for (int val = 1; val <= 9; val++) {
              if ((candidates & (1 << (val - 1))) != 0) {
                // 创建新的谜题状态
                final newCells = List.generate(
                  21,
                  (i) => List.generate(21, (j) {
                    final originalCell = puzzle.getCell(i, j);
                    return Cell(
                      row: originalCell.row,
                      col: originalCell.col,
                      value: originalCell.value,
                      isFixed: originalCell.isFixed,
                    );
                  }),
                );
                newCells[globalR][globalC] = Cell(
                  row: globalR,
                  col: globalC,
                  value: val,
                  isFixed: puzzle.getCell(globalR, globalC).isFixed,
                );

                final newPuzzle = SamuraiBoard(cells: newCells);
                final newCount = _countSolutions(
                  newPuzzle,
                  maxCount: maxCount,
                  isCancelled: isCancelled,
                  count: count,
                );

                if (newCount >= maxCount) return newCount;
              }
            }
            return count;
          }
        }
      }
    }

    // 找到一个解
    return count + 1;
  }

  // 位操作辅助方法
  int _countBits(int bits) {
    int count = 0;
    while (bits > 0) {
      count += bits & 1;
      bits >>= 1;
    }
    return count;
  }

  List<int> _bitsToValues(int bits) {
    final values = <int>[];
    for (int i = 0; i < 9; i++) {
      if ((bits & (1 << i)) != 0) {
        values.add(i + 1);
      }
    }
    return values;
  }

  // 测试辅助方法
  int testCountBits(int bits) => _countBits(bits);
  List<int> testBitsToValues(int bits) => _bitsToValues(bits);

  /// 创建实例
  static SamuraiBitSolver create({
    required SamuraiBoard board,
    Random? random,
  }) => SamuraiBitSolver(board: board, random: random ?? Random());
}
