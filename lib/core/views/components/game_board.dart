import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sudoku/core/models/cell.dart';

/// 通用棋盘组件基类，严格遵循标准数独布局实现
/// 
/// 提供棋盘渲染、单元格交互等通用功能
/// 接受精确的cellSize参数，使用CustomPaint提升性能
abstract class GameBoard<T extends Cell> extends StatefulWidget {

  const GameBoard({
    required this.cellSize,
    super.key,
  });
  final double cellSize;

  @override
  State<GameBoard<T>> createState() => _GameBoardState<T>();

  /// 创建棋盘绘制器（子类必须实现）
  @protected
  CustomPainter createBoardPainter(BuildContext context);

  /// 处理单元格点击（子类必须实现）
  @protected
  void onCellTap(int row, int col);
}

class _GameBoardState<T extends Cell> extends State<GameBoard<T>> {
  final GlobalKey _boardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final boardSize = widget.cellSize * 9;

    return RepaintBoundary(
      child: GestureDetector(
        onTapUp: _handleTap,
        child: SizedBox(
          key: _boardKey,
          width: boardSize,
          height: boardSize,
          child: CustomPaint(
            painter: widget.createBoardPainter(context),
            size: Size(boardSize, boardSize),
          ),
        ),
      ),
    );
  }

  /// 处理点击事件
  void _handleTap(TapUpDetails details) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final localPosition = box.globalToLocal(details.globalPosition);
      final col = (localPosition.dx / widget.cellSize).floor();
      final row = (localPosition.dy / widget.cellSize).floor();

      if (row >= 0 && row < 9 && col >= 0 && col < 9) {
        widget.onCellTap(row, col);
      }
    }
  }
}

/// 通用棋盘绘制器基类
/// 
/// 提供绘制缓存、文本绘制等通用功能
abstract class BaseBoardPainter<T extends Cell> extends CustomPainter {

  BaseBoardPainter({
    required this.cellSize,
    required this.context,
    required this.themeData,
  });
  final double cellSize;
  final BuildContext context;
  final ThemeData themeData;

  /// 绘制缓存
  // ignore: use_late_for_private_fields_and_variables
  Picture? _pictureCache;
  
  /// 上一次的绘制尺寸
  Size? _lastSize;

  @override
  void paint(Canvas canvas, Size size) {
    // 注意：当shouldRepaint返回true时，Flutter会创建新的painter实例
    // 所以这里不需要额外检查，直接绘制即可
    final recorder = PictureRecorder();
    final cacheCanvas = Canvas(recorder);
    
    paintBoard(cacheCanvas, size);
    
    _pictureCache = recorder.endRecording();
    _lastSize = size;
    
    canvas.drawPicture(_pictureCache!);
  }

  /// 绘制棋盘（子类必须实现）
  @protected
  void paintBoard(Canvas canvas, Size size);

  /// 在矩形中心绘制文本
  @protected
  void drawTextInCenter(
    Canvas canvas,
    String text,
    Rect rect,
    TextStyle style,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: style,
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

  /// 比较两个单元格是否相等
  @protected
  bool areCellsEqual(T a, T b) => 
      a.value == b.value &&
      a.isFixed == b.isFixed &&
      a.isSelected == b.isSelected &&
      a.isHighlighted == b.isHighlighted &&
      a.isError == b.isError &&
      a.candidates.length == b.candidates.length &&
      areSetsEqual(a.candidates, b.candidates);

  /// 比较两个集合是否相等
  @protected
  bool areSetsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }
  
  @override
  bool shouldRepaint(covariant BaseBoardPainter oldDelegate) => 
      !identical(this, oldDelegate) ||
      _lastSize != oldDelegate._lastSize;
}
