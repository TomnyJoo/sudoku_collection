import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import 'package:sudoku/games/standard/standard_constants.dart';

class StandardBoardWidget extends GameBoard<Cell> {
  const StandardBoardWidget({
    required this.board,
    required this.onCellSelected,
    required super.cellSize,
    super.key,
  });

  final StandardBoard board;
  final Function(Cell) onCellSelected;

  @override
  CustomPainter createBoardPainter(BuildContext context) {
    final settings = Provider.of<AppSettings>(context, listen: false);
    return StandardBoardPainter(
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

class StandardBoardPainter extends BaseBoardPainter<Cell> {
  StandardBoardPainter({
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
    _drawCells(canvas);
    _drawGrid(canvas, size);
  }

  void _drawCells(Canvas canvas) {
    for (var row = 0; row < StandardConstants.boardSize; row++) {
      for (var col = 0; col < StandardConstants.boardSize; col++) {
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

    final smallCellSize = candidateRect.width / StandardConstants.boxSize;

    for (var num = 1; num <= StandardConstants.boardSize; num++) {
      if (cell.candidates.contains(num)) {
        final row = ((num - 1) ~/ StandardConstants.boxSize).floor();
        final col = ((num - 1) % StandardConstants.boxSize).floor();

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

    for (var i = 0; i <= StandardConstants.boardSize; i++) {
      final x = i * cellSize;
      final lineWidth = (i % StandardConstants.boxSize == 0) ? 3.0 : 1.0;
      paint
        ..strokeWidth = lineWidth
        ..color = (i % StandardConstants.boxSize == 0) ? context.boardGridLineBoldColor : context.boardGridLineColor;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var i = 0; i <= StandardConstants.boardSize; i++) {
      final y = i * cellSize;
      final lineWidth = (i % StandardConstants.boxSize == 0) ? 3.0 : 1.0;
      paint
        ..strokeWidth = lineWidth
        ..color = (i % StandardConstants.boxSize == 0) ? context.boardGridLineBoldColor : context.boardGridLineColor;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StandardBoardPainter oldDelegate) {
    if (oldDelegate.cellSize != cellSize) return true;
    if (oldDelegate.themeData != themeData) return true;
    if (oldDelegate.highlightMistakesEnabled != highlightMistakesEnabled) return true;
    
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
