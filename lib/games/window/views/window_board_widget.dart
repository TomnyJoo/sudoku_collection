import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/window/models/window_board.dart';
import 'package:sudoku/games/window/window_constants.dart';

class WindowBoardWidget extends GameBoard<Cell> {

  const WindowBoardWidget({
    required this.board,
    required this.onCellSelected,
    required super.cellSize,
    super.key,
  });
  final WindowBoard board;
  final Function(Cell) onCellSelected;

  @override
  CustomPainter createBoardPainter(BuildContext context) {
    final settings = Provider.of<AppSettings>(context, listen: false);
    return WindowBoardPainter(
      board: board.cells,
      cellSize: cellSize,
      context: context,
      highlightMistakesEnabled: settings.highlightMistakesEnabled,
      themeData: Theme.of(context),
    );
  }

  @override
  void onCellTap(int row, int col) {
    onCellSelected(board.cells[row][col]);
  }
}

class WindowBoardPainter extends BaseBoardPainter<Cell> {

  WindowBoardPainter({
    required this.board,
    required super.cellSize,
    required super.context,
    required this.highlightMistakesEnabled,
    required super.themeData,
  });
  final List<List<Cell>> board;
  final bool highlightMistakesEnabled;

  @override
  void paintBoard(Canvas canvas, Size size) {
    _drawWindowBackgrounds(canvas);
    _drawCells(canvas);
    _drawGrid(canvas, size);
  }

  /// 绘制窗口区域背景色
  void _drawWindowBackgrounds(Canvas canvas) {
    for (final windowRegion in WindowConstants.windowRegions) {
      final windowRect = Rect.fromLTWH(
        windowRegion.startCol * cellSize,
        windowRegion.startRow * cellSize,
        windowRegion.width * cellSize,
        windowRegion.height * cellSize,
      );

      final paint = Paint()
        ..color = context.boardWindowBackgroundColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(windowRect, paint);
    }
  }

  void _drawCells(Canvas canvas) {
    for (var row = 0; row < WindowConstants.boardSize; row++) {
      for (var col = 0; col < WindowConstants.boardSize; col++) {
        final cell = board[row][col];
        final cellRect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );

        _drawCellBackground(canvas, cell, cellRect, themeData);
        _drawCellValue(canvas, cell, cellRect, themeData);
      }
    }
  }

  void _drawCellBackground(Canvas canvas, Cell cell, Rect cellRect, ThemeData theme) {
    final paint = Paint();

    if (cell.isSelected) {
      paint.color = context.boardSelectedCellColor;
    } else if (cell.isHighlighted) {
      paint.color = context.boardHighlightedCellColor.withAlpha(0x99);
    } else {
      // ⭐ 检查单元格是否在窗口区域内
      // 如果在窗口区域内,不绘制默认背景(保留窗口背景色)
      // 如果不在窗口区域内,绘制默认单元格背景
      if (!_isCellInWindowRegion(cell.row, cell.col)) {
        paint.color = context.boardCellBackgroundColor;
      } else {
        // 在窗口区域内,使用窗口背景色
        paint.color = context.boardWindowBackgroundColor;
      }
    }

    canvas.drawRect(cellRect, paint);
  }

  /// 检查指定位置的单元格是否在窗口区域内
  bool _isCellInWindowRegion(int row, int col) {
    for (final windowRegion in WindowConstants.windowRegions) {
      if (row >= windowRegion.startRow &&
          row <= windowRegion.endRow &&
          col >= windowRegion.startCol &&
          col <= windowRegion.endCol) {
        return true;
      }
    }
    return false;
  }

  void _drawCellValue(Canvas canvas, Cell cell, Rect cellRect, ThemeData theme) {
    if (cell.value != null) {
      final textStyle = cell.isFixed
          ? AppTextStyles.cellFixed.copyWith(
              color: context.boardFixedValueColor,
              fontWeight: FontWeight.bold,
            )
          : AppTextStyles.cellUser.copyWith(
              color: (highlightMistakesEnabled && cell.isError)
                  ? context.errorColor
                  : context.boardUserValueColor,
            );

      drawTextInCenter(
        canvas,
        cell.value.toString(),
        cellRect,
        textStyle,
      );
    } else if (cell.candidates.isNotEmpty) {
      _drawCandidates(canvas, cell, cellRect);
    }
  }

  void _drawCandidates(Canvas canvas, Cell cell, Rect cellRect) {
    final candidateColor = context.boardMarkerColor;
    
    final candidateRect = Rect.fromLTWH(
      cellRect.left + 2,
      cellRect.top + 2,
      cellRect.width - 4,
      cellRect.height - 4,
    );

    final smallCellSize = candidateRect.width / 3;

    for (var num = 1; num <= 9; num++) {
      if (cell.candidates.contains(num)) {
        final row = ((num - 1) ~/ 3).floor();
        final col = ((num - 1) % 3).floor();

        final textRect = Rect.fromLTWH(
          candidateRect.left + col * smallCellSize,
          candidateRect.top + row * smallCellSize,
          smallCellSize,
          smallCellSize,
        );

        drawTextInCenter(
          canvas,
          num.toString(),
          textRect,
          AppTextStyles.candidate.copyWith(
            color: candidateColor,
          ),
        );
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = context.boardGridLineColor
      ..strokeWidth = 1.0;

    final thickPaint = Paint()
      ..color = context.boardGridLineBoldColor
      ..strokeWidth = 2.5;

    // 绘制横线
    for (var i = 0; i <= WindowConstants.boardSize; i++) {
      final y = i * cellSize;
      final paint = (i % 3 == 0) ? thickPaint : thinPaint;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 绘制竖线
    for (var i = 0; i <= WindowConstants.boardSize; i++) {
      final x = i * cellSize;
      final paint = (i % 3 == 0) ? thickPaint : thinPaint;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  // ⭐ 窗口边框绘制已弃用,改用背景色方案
  // 保留此方法以备将来需要,但当前不再调用
  // void _drawWindows(Canvas canvas, Size size) { ... }
  // void _drawWindowBorderLine(Canvas canvas, Offset start, Offset end) { ... }

  @override
  bool shouldRepaint(covariant WindowBoardPainter oldDelegate) => oldDelegate.board != board ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.highlightMistakesEnabled != highlightMistakesEnabled;
}
