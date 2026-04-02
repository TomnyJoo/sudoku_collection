import 'package:flutter/material.dart';
import 'package:sudoku/common/l10n/localization_utils.dart';
import 'package:sudoku/common/theme/theme_extension.dart';
import 'package:sudoku/core/index.dart';

/// 功能键盘组件
///
/// 显示游戏控制按钮，包括：
/// - 撤销/重做
/// - 提示
/// - 标记模式
/// - 自动标记
/// - 清除
/// - 显示答案
/// - 重置游戏
/// - 新游戏
class FunctionKeyboard extends StatefulWidget {
  const FunctionKeyboard({
    required this.onUndo,
    required this.onRedo,
    required this.onHint,
    required this.onMark,
    required this.onErase,
    required this.onReset,
    required this.onAutoMark,
    required this.onSolution,
    required this.onNew,
    required this.buttonSize,
    this.isMarkMode,
    this.isAutoMarkMode,
    super.key,
  });
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final ValueChanged<BuildContext> onHint;
  final VoidCallback onMark;
  final VoidCallback onErase;
  final VoidCallback onReset;
  final VoidCallback onAutoMark;
  final VoidCallback onSolution;
  final VoidCallback onNew;
  final double buttonSize;
  final bool Function()? isMarkMode;
  final bool Function()? isAutoMarkMode;

  @override
  State<FunctionKeyboard> createState() => _FunctionKeyboardState();
}

class _FunctionKeyboardState extends State<FunctionKeyboard> {
  @override
  Widget build(final BuildContext context) {
    final buttonSize = widget.buttonSize;
    const spacing = AppConstants.keyboardButtonSpacing;
    const padding = AppConstants.keyboardPadding;

    return Container(
      padding: const EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (final row) => Padding(
            padding: EdgeInsets.only(bottom: row < 2 ? spacing : 0),
            child: SizedBox(
              height: buttonSize,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (final col) {
                  final index = row * 3 + col;
                  return Padding(
                    padding: EdgeInsets.only(right: col < 2 ? spacing : 0),
                    child: _buildControlButton(
                      _getIconForIndex(index),
                      _getLabelForIndex(index),
                      _getCallbackForIndex(index),
                      index,
                      buttonSize,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForIndex(final int index) {
    switch (index) {
      case 0:
        return Icons.undo;
      case 1:
        return Icons.redo;
      case 2:
        return Icons.lightbulb_outline;
      case 3:
        return Icons.edit;
      case 4:
        return Icons.auto_fix_high;
      case 5:
        return Icons.clear;
      case 6:
        return Icons.visibility;
      case 7:
        return Icons.refresh;
      case 8:
        return Icons.add;
      default:
        return Icons.error;
    }
  }

  String _getLabelForIndex(final int index) {
    final localization = LocalizationUtils.of(context);
    switch (index) {
      case 0:
        return localization?.undo ?? 'Undo';
      case 1:
        return localization?.redo ?? 'Redo';
      case 2:
        return localization?.hint ?? 'Hint';
      case 3:
        return localization?.mark ?? 'Mark';
      case 4:
        return localization?.autoMark ?? 'Auto Mark';
      case 5:
        return localization?.erase ?? 'Erase';
      case 6:
        return localization?.solution ?? 'Solution';
      case 7:
        return localization?.reset ?? 'Reset';
      case 8:
        return localization?.newGame ?? 'New Game';
      default:
        return localization?.undo ?? 'Error';
    }
  }

  VoidCallback _getCallbackForIndex(final int index) {
    switch (index) {
      case 0:
        return widget.onUndo;
      case 1:
        return widget.onRedo;
      case 2:
        return () => widget.onHint(context);
      case 3:
        return widget.onMark;
      case 4:
        return widget.onAutoMark;
      case 5:
        return widget.onErase;
      case 6:
        return widget.onSolution;
      case 7:
        return widget.onReset;
      case 8:
        return widget.onNew;
      default:
        return () {};
    }
  }

  Widget _buildControlButton(
    final IconData icon,
    final String label,
    final VoidCallback onPressed,
    final int index,
    final double buttonSize,
  ) {
    final isTargetButton = index == 3 || index == 4;
    final isPressed =
        isTargetButton &&
        (index == 3
            ? (widget.isMarkMode?.call() ?? false)
            : (widget.isAutoMarkMode?.call() ?? false));

    final iconSize = buttonSize * 0.40;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isPressed
              ? LinearGradient(
                  colors: [context.primaryColor, context.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    context.primaryColor.withAlpha(0x33),
                    context.secondaryColor.withAlpha(0x33),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(0x33),
              blurRadius: isPressed ? 6 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isPressed ? Colors.white : context.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: () {
            onPressed();
            if (isTargetButton) {
              setState(() {});
            }
          },
          child: Icon(
            icon,
            size: iconSize,
            semanticLabel: label,
            color: isPressed ? Colors.white : context.primaryColor,
          ),
        ),
      ),
    );
  }
}
