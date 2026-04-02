import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/killer/killer_constants.dart';
import 'package:sudoku/games/killer/models/index.dart';

class KillerBoardWidget extends GameBoard<Cell> {

  const KillerBoardWidget({
    required this.board,
    required this.onCellSelected,
    required super.cellSize,
    super.key,
  });
  final KillerBoard board;
  final Function(Cell) onCellSelected;

  @override
  CustomPainter createBoardPainter(BuildContext context) {
    final settings = Provider.of<AppSettings>(context, listen: false);
    return KillerBoardPainter(
      board: board,
      cellSize: cellSize,
      context: context,
      showCageSums: true,
      showCageBorders: true,
      highlightMistakesEnabled: settings.highlightMistakesEnabled,
      themeData: Theme.of(context),
    );
  }

  @override
  void onCellTap(int row, int col) {
    onCellSelected(board.getCell(row, col));
  }
}

class KillerBoardPainter extends BaseBoardPainter<Cell> {

  KillerBoardPainter({
    required this.board,
    required super.cellSize,
    required super.context,
    required this.showCageSums,
    required this.showCageBorders,
    required this.highlightMistakesEnabled,
    required super.themeData,
  });
  final KillerBoard board;
  final bool showCageSums;
  final bool showCageBorders;
  final bool highlightMistakesEnabled;

  late final Map<String, int> _cageColorMap = _buildCageColorMap();



  @override
  void paintBoard(Canvas canvas, Size size) {
    _drawCageBackgrounds(canvas);
    _drawCells(canvas);
    _drawGrid(canvas, size);
    if (showCageSums) {
      _drawCageSums(canvas);
    }
  }

  void _drawCageBackgrounds(Canvas canvas) {
    for (final cage in board.cages) {
      final colorIndex = _cageColorMap[cage.id] ?? 0;
      final cageColor = context.getBoardCageColor(colorIndex).withValues(alpha: 0.55);

      final paint = Paint()
        ..color = cageColor
        ..style = PaintingStyle.fill;

      for (final coord in cage.cellCoordinates) {
        final cellRect = Rect.fromLTWH(
          coord.$2 * cellSize,
          coord.$1 * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(cellRect, paint);
      }
    }
  }
  
  /// 构建cage颜色映射 - 确保相邻cage使用不同颜色
  Map<String, int> _buildCageColorMap() {
    final colorMap = <String, int>{};

    if (board.cages.isEmpty) return colorMap;

    final sortedCages = board.cages.toList()
      ..sort((a, b) => b.cellCount.compareTo(a.cellCount));

    final colorUsage = <int, Set<String>>{};

    for (final cage in sortedCages) {
      final adjacentCages = _findAdjacentCages(cage, board.cages);
      final usedColors = adjacentCages
          .where((c) => colorMap.containsKey(c.id))
          .map((c) => colorMap[c.id]!)
          .toSet();

      var colorIndex = 0;
      while (usedColors.contains(colorIndex) && colorIndex < 8) {
        colorIndex++;
      }

      colorMap[cage.id] = colorIndex;
      colorUsage[colorIndex] = (colorUsage[colorIndex] ?? {})..add(cage.id);
    }

    return colorMap;
  }
  
  /// 检测相邻cage
  List<KillerCage> _findAdjacentCages(KillerCage cage, List<KillerCage> allCages) {
    final adjacent = <KillerCage>[];
    
    for (final other in allCages) {
      if (other.id == cage.id) continue;
      
      // 检查是否有相邻单元格
      for (final coord in cage.cellCoordinates) {
        final neighbors = [
          (coord.$1 - 1, coord.$2), // 上
          (coord.$1 + 1, coord.$2), // 下
          (coord.$1, coord.$2 - 1), // 左
          (coord.$1, coord.$2 + 1), // 右
        ];
        
        for (final neighbor in neighbors) {
          if (other.cellCoordinates.contains(neighbor)) {
            adjacent.add(other);
            break;
          }
        }
        if (adjacent.contains(other)) break;
      }
    }
    
    return adjacent;
  }

  void _drawCells(Canvas canvas) {
    for (var row = 0; row < KillerConstants.boardSize; row++) {
      for (var col = 0; col < KillerConstants.boardSize; col++) {
        final cell = board.getCell(row, col);
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
      canvas.drawRect(cellRect, paint);
    } else if (cell.isHighlighted) {
      paint.color = context.boardHighlightedCellColor.withAlpha(0x99);
      canvas.drawRect(cellRect, paint);
    }
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
    final candidateFontSize = _calculateCandidateFontSize(cellRect.width);
    final candidateColor = _getCandidateColor();

    final candidateRect = Rect.fromLTWH(
      cellRect.left + 1,
      cellRect.top + 1,
      cellRect.width - 2,
      cellRect.height - 2,
    );

    final smallCellSize = candidateRect.width / KillerConstants.boxSize;

    for (var num = 1; num <= KillerConstants.boardSize; num++) {
      if (cell.candidates.contains(num)) {
        final row = ((num - 1) ~/ KillerConstants.boxSize).floor();
        final col = ((num - 1) % KillerConstants.boxSize).floor();

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
          TextStyle(
            fontSize: candidateFontSize,
            fontWeight: FontWeight.w500,
            color: candidateColor,
            height: 1.0,
          ),
        );
      }
    }
  }

  double _calculateCandidateFontSize(double cellWidth) => (cellWidth / 3.5).clamp(9.0, 14.0);

  Color _getCandidateColor() => context.isDarkMode
      ? const Color(0xFFE5E7EB)
      : const Color(0xFF374151);

  void _drawCageSums(Canvas canvas) {
    for (final cage in board.cages) {
      final position = _findBestSumPosition(cage);

      final cellRect = Rect.fromLTWH(
        position.$2 * cellSize,
        position.$1 * cellSize,
        cellSize,
        cellSize,
      );

      const sumFontSize = 11.0;
      final sumText = TextSpan(
        text: cage.sum.toString(),
        style: TextStyle(
          fontSize: sumFontSize,
          fontWeight: FontWeight.w700,
          color: context.isDarkMode ? const Color(0xFFFF6B35) : const Color(0xFFD84315),
          height: 1.0,
        ),
      );

      final textPainter = TextPainter(
        text: sumText,
        textDirection: TextDirection.ltr,
      )..layout();

      const padding = 2.0;
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cellRect.left + 2,
          cellRect.top + 2,
          textPainter.width + padding * 2,
          textPainter.height + padding,
        ),
        const Radius.circular(3),
      );

      final bgPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(bgRect, bgPaint);

      final x = cellRect.left + 2 + padding;
      final y = cellRect.top + 2 + padding / 2;
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  (int, int) _findBestSumPosition(KillerCage cage) {
    for (final coord in cage.cellCoordinates) {
      final cell = board.getCell(coord.$1, coord.$2);
      if (cell.value != null) {
        return coord;
      }
    }

    for (final coord in cage.cellCoordinates) {
      final cell = board.getCell(coord.$1, coord.$2);
      if (cell.candidates.isEmpty) {
        return coord;
      }
    }

    var bestCoord = cage.cellCoordinates.first;
    var minCandidates = 10;

    for (final coord in cage.cellCoordinates) {
      final cell = board.getCell(coord.$1, coord.$2);
      if (cell.candidates.length < minCandidates) {
        minCandidates = cell.candidates.length;
        bestCoord = coord;
      }
    }

    return bestCoord;
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i <= KillerConstants.boardSize; i++) {
      final x = i * cellSize;
      final lineWidth = (i % KillerConstants.boxSize == 0) ? 3.0 : 1.0;
      paint..strokeWidth = lineWidth
      ..color = (i % KillerConstants.boxSize == 0) ? context.boardGridLineBoldColor : context.boardGridLineColor;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var i = 0; i <= KillerConstants.boardSize; i++) {
      final y = i * cellSize;
      final lineWidth = (i % KillerConstants.boxSize == 0) ? 3.0 : 1.0;
      paint..strokeWidth = lineWidth
      ..color = (i % KillerConstants.boxSize == 0) ? context.boardGridLineBoldColor : context.boardGridLineColor;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant KillerBoardPainter oldDelegate) {
    if (oldDelegate.cellSize != cellSize) return true;
    if (oldDelegate.themeData != themeData) return true;
    if (oldDelegate.showCageSums != showCageSums) return true;
    if (oldDelegate.showCageBorders != showCageBorders) return true;
    if (oldDelegate.highlightMistakesEnabled != highlightMistakesEnabled) return true;
    
    // 检查 board 是否变化
    if (oldDelegate.board.stateHash != board.stateHash) return true;
    
    // 检查 cages 是否变化
    if (oldDelegate.board.cages.length != board.cages.length) return true;
    for (var i = 0; i < board.cages.length; i++) {
      if (oldDelegate.board.cages[i].id != board.cages[i].id ||
          oldDelegate.board.cages[i].sum != board.cages[i].sum ||
          oldDelegate.board.cages[i].cellCount != board.cages[i].cellCount) {
        return true;
      }
    }
    
    return false;
  }
}
