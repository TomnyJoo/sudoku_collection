import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/diagonal_constants.dart';
import 'package:sudoku/games/diagonal/models/index.dart';

class DiagonalBoardWidget extends GameBoard<Cell> {

  const DiagonalBoardWidget({
    required this.board,
    required this.onCellSelected,
    required super.cellSize,
    this.showDiagonalLines = true,
    super.key,
  });
  final DiagonalBoard board;
  final Function(Cell) onCellSelected;
  final bool showDiagonalLines;

  @override
  CustomPainter createBoardPainter(BuildContext context) {
    final settings = Provider.of<AppSettings>(context, listen: false);
    return DiagonalBoardPainter(
      board: board.cells,
      cellSize: cellSize,
      context: context,
      highlightMistakesEnabled: settings.highlightMistakesEnabled,
      showDiagonalLines: showDiagonalLines,
      themeData: Theme.of(context),
    );
  }

  @override
  void onCellTap(int row, int col) {
    onCellSelected(board.cells[row][col]);
  }
}

class DiagonalBoardPainter extends BaseBoardPainter<Cell> {

  DiagonalBoardPainter({
    required this.board,
    required super.cellSize,
    required super.context,
    required this.highlightMistakesEnabled,
    required this.showDiagonalLines,
    required super.themeData,
  });
  final List<List<Cell>> board;
  final bool highlightMistakesEnabled;
  final bool showDiagonalLines;

  @override
  void paintBoard(Canvas canvas, Size size) {
    _drawCells(canvas);
    _drawGrid(canvas, size);
    if (showDiagonalLines) {
      _drawDiagonalLines(canvas, size);
    }
  }

  void _drawCells(Canvas canvas) {
    for (var row = 0; row < DiagonalConstants.boardSize; row++) {
      for (var col = 0; col < DiagonalConstants.boardSize; col++) {
        final cell = board[row][col];
        final cellRect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );

        _drawCellBackground(canvas, cell, cellRect, themeData, row, col);
        _drawCellValue(canvas, cell, cellRect, themeData);
      }
    }
  }

  void _drawCellBackground(Canvas canvas, Cell cell, Rect cellRect, ThemeData theme, int row, int col) {
    final paint = Paint();
    
    // 检查是否在对角线上
    final isOnMainDiagonal = row == col;
    final isOnAntiDiagonal = row + col == DiagonalConstants.boardSize - 1;
    final isOnDiagonal = isOnMainDiagonal || isOnAntiDiagonal;
    
    if (cell.isSelected) {
      paint.color = context.boardSelectedCellColor;
    } else if (cell.isHighlighted) {
      paint.color = context.boardHighlightedCellColor.withAlpha(0x99);
    } else if (isOnDiagonal) {
      paint.color = context.boardCellBackgroundColor.withAlpha(0x99);
    } else {
      paint.color = context.boardCellBackgroundColor;
    }
    
    canvas.drawRect(cellRect, paint);
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
      _drawCandidates(canvas, cell, cellRect, theme);
    }
  }

  void _drawCandidates(Canvas canvas, Cell cell, Rect cellRect, ThemeData theme) {
    final candidateColor = context.boardMarkerColor;
    
    final candidateRect = Rect.fromLTWH(
      cellRect.left + 2,
      cellRect.top + 2,
      cellRect.width - 4,
      cellRect.height - 4,
    );

    final smallCellSize = candidateRect.width / DiagonalConstants.boxSize;

    for (var num = 1; num <= DiagonalConstants.boardSize; num++) {
      if (cell.candidates.contains(num)) {
        final row = ((num - 1) ~/ DiagonalConstants.boxSize).floor();
        final col = ((num - 1) % DiagonalConstants.boxSize).floor();

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
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i <= DiagonalConstants.boardSize; i++) {
      final x = i * cellSize;
      final lineWidth = (i % DiagonalConstants.boxSize == 0) ? 3.0 : 1.0;
      paint..strokeWidth = lineWidth
      ..color = (i % DiagonalConstants.boxSize == 0) ? context.boardGridLineBoldColor : context.boardGridLineColor;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var i = 0; i <= DiagonalConstants.boardSize; i++) {
      final y = i * cellSize;
      final lineWidth = (i % DiagonalConstants.boxSize == 0) ? 3.0 : 1.0;
      paint..strokeWidth = lineWidth
      ..color = (i % DiagonalConstants.boxSize == 0) ? context.boardGridLineBoldColor : context.boardGridLineColor;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawDiagonalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..color = context.boardGridLineBoldColor.withAlpha(0x80);

    // 主对角线（左上到右下）
    _drawDashedLine(
      canvas,
      Offset.zero,
      Offset(size.width, size.height),
      paint,
    );

    // 副对角线（右上到左下）
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    
    final totalLength = (end - start).distance;
    final dashCount = (totalLength / (dashLength + gapLength)).floor();
    
    final dx = (end.dx - start.dx) / totalLength;
    final dy = (end.dy - start.dy) / totalLength;

    for (var i = 0; i < dashCount; i++) {
      final dashStart = i * (dashLength + gapLength);
      final dashEnd = dashStart + dashLength;
      
      canvas.drawLine(
        Offset(
          start.dx + dx * dashStart,
          start.dy + dy * dashStart,
        ),
        Offset(
          start.dx + dx * dashEnd,
          start.dy + dy * dashEnd,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DiagonalBoardPainter oldDelegate) {
    if (oldDelegate.cellSize != cellSize) return true;
    if (oldDelegate.themeData != themeData) return true;
    if (oldDelegate.highlightMistakesEnabled != highlightMistakesEnabled) return true;
    if (oldDelegate.showDiagonalLines != showDiagonalLines) return true;
    
    if (oldDelegate.board.length != board.length) return true;
    
    for (var i = 0; i < board.length; i++) {
      if (oldDelegate.board[i].length != board[i].length) return true;
      for (var j = 0; j < board[i].length; j++) {
        if (!areCellsEqual(oldDelegate.board[i][j], board[i][j])) {
          return true;
        }
      }
    }
    
    return false;
  }
}
