import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/jigsaw/models/jigsaw_board.dart';

class JigsawBoardWidget extends StatelessWidget {
  const JigsawBoardWidget({
    required this.board,
    required this.onCellSelected,
    required this.cellSize,
    this.showRegionNumbers = true,
    super.key,
  });
  final JigsawBoard board;
  final Function(Cell) onCellSelected;
  final double cellSize;
  final bool showRegionNumbers;

  @override
  Widget build(final BuildContext context) {
    final settings = Provider.of<AppSettings>(context, listen: false);
    final boardSize = cellSize * 9;

    return RepaintBoundary(
      child: GestureDetector(
        onTapUp: (final TapUpDetails details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final localPosition = box.globalToLocal(details.globalPosition);
            final col = (localPosition.dx / cellSize).floor();
            final row = (localPosition.dy / cellSize).floor();

            if (row >= 0 && row < 9 && col >= 0 && col < 9) {
              onCellSelected(board.cells[row][col]);
            }
          }
        },
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: CustomPaint(
            painter: JigsawBoardPainter(
              board: board,
              cellSize: cellSize,
              context: context,
              highlightMistakesEnabled: settings.highlightMistakesEnabled,
              themeData: Theme.of(context),
              showRegionNumbers: showRegionNumbers,
            ),
            size: Size(boardSize, boardSize),
          ),
        ),
      ),
    );
  }
}

class JigsawBoardPainter extends CustomPainter {
  JigsawBoardPainter({
    required this.board,
    required this.cellSize,
    required this.context,
    required this.highlightMistakesEnabled,
    required this.themeData,
    this.showRegionNumbers = true,
  });
  final JigsawBoard board;
  final double cellSize;
  final BuildContext context;
  final bool highlightMistakesEnabled;
  final ThemeData themeData;
  final bool showRegionNumbers;

  List<List<int>> get regionMatrix => board.regionMatrix ?? List.generate(9, (_) => List.filled(9, 0));

  Map<int, List<(int, int)>>? _regionCellsCache;
  Map<int, (int, int)>? _regionMinCellCache;

  Map<int, List<(int, int)>> _getRegionCellsCache() {
    if (_regionCellsCache != null) {
      return _regionCellsCache!;
    }

    final cache = <int, List<(int, int)>>{};
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        final regionId = regionMatrix[i][j];
        cache.putIfAbsent(regionId, () => []);
        cache[regionId]!.add((i, j));
      }
    }

    _regionCellsCache = cache;
    return cache;
  }

  Map<int, (int, int)> _getRegionMinCellCache() {
    if (_regionMinCellCache != null) {
      return _regionMinCellCache!;
    }

    final cache = <int, (int, int)>{};
    for (int regionId = 0; regionId < 9; regionId++) {
      final regionCells = _getRegionCellsCache()[regionId] ?? [];
      if (regionCells.isEmpty) continue;

      int minRow = 9, minCol = 9;
      for (final cell in regionCells) {
        if (cell.$1 < minRow || (cell.$1 == minRow && cell.$2 < minCol)) {
          minRow = cell.$1;
          minCol = cell.$2;
        }
      }

      cache[regionId] = (minRow, minCol);
    }

    _regionMinCellCache = cache;
    return cache;
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    _drawCells(canvas);
    _drawRegionNumbers(canvas);
    _drawGrid(canvas, size);
    _drawRegionBoundaries(canvas, size);
  }

  void _drawGrid(final Canvas canvas, final Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = context.boardGridLineColor;

    // 绘制垂直线
    for (var i = 0; i <= 9; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 绘制水平线
    for (var i = 0; i <= 9; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawRegionBoundaries(final Canvas canvas, final Size size) {
    final boundaryPaint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..color = context.primaryColor;

    final regionCellsCache = _getRegionCellsCache();

    for (var regionId = 0; regionId < 9; regionId++) {
      final regionCells = regionCellsCache[regionId] ?? [];
      if (regionCells.isEmpty) continue;

      for (final cell in regionCells) {
        final cellRect = Rect.fromLTWH(
          cell.$2 * cellSize,
          cell.$1 * cellSize,
          cellSize,
          cellSize,
        );

        final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];
        for (final neighbor in directions) {
          final newRow = cell.$1 + neighbor.$1;
          final newCol = cell.$2 + neighbor.$2;

          if (newRow >= 0 && newRow < 9 && newCol >= 0 && newCol < 9) {
            final neighborRegionId = regionMatrix[newRow][newCol];
            if (neighborRegionId != regionId) {
              _drawBoundaryBetweenCells(canvas, cellRect, neighbor, boundaryPaint);
            }
          } else {
            _drawBoundaryBetweenCells(canvas, cellRect, neighbor, boundaryPaint);
          }
        }
      }
    }
  }

  void _drawBoundaryBetweenCells(
    final Canvas canvas,
    final Rect cellRect,
    final (int, int) direction,
    final Paint paint,
  ) {
    if (direction.$1 == -1) {
      canvas.drawLine(cellRect.topLeft, cellRect.topRight, paint);
    } else if (direction.$1 == 1) {
      canvas.drawLine(cellRect.bottomLeft, cellRect.bottomRight, paint);
    } else if (direction.$2 == -1) {
      canvas.drawLine(cellRect.topLeft, cellRect.bottomLeft, paint);
    } else if (direction.$2 == 1) {
      canvas.drawLine(cellRect.topRight, cellRect.bottomRight, paint);
    }
  }

  void _drawCells(final Canvas canvas) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final cell = board.cells[row][col];
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

  void _drawCellBackground(final Canvas canvas, final Cell cell, final Rect cellRect, final ThemeData theme) {
    final paint = Paint();
    
    if (cell.isSelected) {
      paint.color = context.boardSelectedCellColor;
    } else if (cell.isHighlighted) {
      paint.color = context.boardHighlightedCellColor.withAlpha(0x99);
    } else {
      paint.color = _getRegionBackgroundColor(cell);
    }
    
    canvas.drawRect(cellRect, paint);
    
    if (cell.isSelected) {
      _drawRegionHighlight(canvas, cell);
    }
  }

  void _drawRegionHighlight(final Canvas canvas, final Cell cell) {
    final regionId = regionMatrix[cell.row][cell.col];
    final regionCells = _getRegionCellsCache()[regionId] ?? [];
    
    final highlightPaint = Paint()
      ..color = context.boardSelectedCellColor.withAlpha(0x30)
      ..style = PaintingStyle.fill;
    
    for (final regionCell in regionCells) {
      if (regionCell.$1 == cell.row && regionCell.$2 == cell.col) continue;
      
      final cellRect = Rect.fromLTWH(
        regionCell.$2 * cellSize,
        regionCell.$1 * cellSize,
        cellSize,
        cellSize,
      );
      
      canvas.drawRect(cellRect, highlightPaint);
    }
  }

  Color _getRegionBackgroundColor(final Cell cell) {
    final regionId = regionMatrix[cell.row][cell.col];
    if (regionId < 0 || regionId >= 9) {
      return context.boardCellBackgroundColor;
    }

    final colors = context.boardRegionColors;
    return colors[regionId % colors.length];
  }

  void _drawRegionNumbers(final Canvas canvas) {
    if (!showRegionNumbers) return;

    final regionMinCellCache = _getRegionMinCellCache();

    for (var regionId = 0; regionId < 9; regionId++) {
      final minCell = regionMinCellCache[regionId];
      if (minCell == null) continue;

      final cellRect = Rect.fromLTWH(
        minCell.$2 * cellSize,
        minCell.$1 * cellSize,
        cellSize,
        cellSize,
      );

      final circleRadius = cellSize * 0.18;
      final circleCenter = Offset(
        cellRect.left + cellSize * 0.2,
        cellRect.top + cellSize * 0.2,
      );

      final circlePaint = Paint()
        ..color = context.boardRegionNumberColor.withAlpha(0x80)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(circleCenter, circleRadius, circlePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: (regionId + 1).toString(),
          style: AppTextStyles.candidate.copyWith(
            color: context.boardRegionNumberColor,
            fontSize: cellSize * 0.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )

      ..layout();

      final offset = Offset(
        circleCenter.dx - textPainter.width / 2,
        circleCenter.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  void _drawCellValue(final Canvas canvas, final Cell cell, final Rect cellRect, final ThemeData theme) {
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

      _drawTextInCenter(
        canvas,
        cell.value.toString(),
        cellRect,
        textStyle,
      );
    } else if (cell.candidates.isNotEmpty) {
      _drawCandidates(canvas, cell, cellRect, theme);
    }
  }

  void _drawCandidates(final Canvas canvas, final Cell cell, final Rect cellRect, final ThemeData theme) {
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

        _drawTextInCenter(
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

  void _drawTextInCenter(final Canvas canvas, final String text, final Rect rect, final TextStyle style) {
    final responsiveFontSize = ResponsiveLayout.getResponsiveFontSize(style.fontSize ?? 16, context);
    final responsiveStyle = style.copyWith(fontSize: responsiveFontSize);

    final textSpan = TextSpan(
      text: text,
      style: responsiveStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )
    ..layout();

    final offsetX = rect.center.dx - textPainter.width / 2;
    final offsetY = rect.center.dy - textPainter.height / 2;
    final offset = Offset(offsetX, offsetY);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant final JigsawBoardPainter oldDelegate) {
    if (oldDelegate.cellSize != cellSize) return true;
    if (oldDelegate.showRegionNumbers != showRegionNumbers) return true;
    if (oldDelegate.themeData != themeData) return true;

    final cells = board.cells;
    final oldCells = oldDelegate.board.cells;

    if (oldCells.length != cells.length) return true;

    for (var i = 0; i < cells.length; i++) {
      if (oldCells[i].length != cells[i].length) return true;
      for (var j = 0; j < cells[i].length; j++) {
        if (!_areCellsEqual(oldCells[i][j], cells[i][j])) {
          return true;
        }
      }
    }

    return false;
  }

  bool _areCellsEqual(final Cell a, final Cell b) => a.value == b.value &&
         a.isFixed == b.isFixed &&
         a.isSelected == b.isSelected &&
         a.isHighlighted == b.isHighlighted &&
         a.isError == b.isError &&
         a.candidates.length == b.candidates.length &&
         _areSetsEqual(a.candidates, b.candidates);

  bool _areSetsEqual(final Set<int> a, final Set<int> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }
}
