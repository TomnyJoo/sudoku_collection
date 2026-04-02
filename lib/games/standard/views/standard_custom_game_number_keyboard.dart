import 'package:flutter/material.dart';
import 'package:sudoku/common/theme/index.dart';
import 'package:sudoku/core/index.dart';

/// 自定义游戏页面的数字键盘组件
class StandardCustomGameNumberKeyboard extends StatelessWidget {
  const StandardCustomGameNumberKeyboard({
    required this.onNumberSelected,
    required this.buttonSize,
    required this.board,
    super.key,
  });
  
  /// 数字输入回调（传入null表示清除）
  final Function(int?) onNumberSelected;  
  /// 自定义按钮尺寸（必须提供）
  final double buttonSize;  
  /// 当前棋盘状态
  final Board board;

  @override
  Widget build(final BuildContext context) {
    const spacing = AppConstants.keyboardButtonSpacing;
    const padding = AppConstants.keyboardPadding;

    return Container(
      padding: const EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (final row) => Padding(
            padding: EdgeInsets.only(
              bottom: row < 2 ? spacing : 0,
            ),
            child: SizedBox(
              height: buttonSize,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (final col) {
                  final number = row * 3 + col + 1;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: col < 2 ? spacing : 0,
                    ),
                    child: _buildButton(context, number, number.toString(), buttonSize),
                  );
                }),
              ),
            ),
          )),
      ),
    );
  }

  Widget _buildButton(final BuildContext context, final int number, final String label, final double buttonSize) {
    final fontSize = buttonSize * AppConstants.keyboardFontScale;
    final counts = board.calculateNumberCounts();
    final count = counts[number] ?? 0;
    
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.primaryColor.withAlpha(AppConstants.gradientAlpha), context.secondaryColor.withAlpha(AppConstants.gradientAlpha)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(AppConstants.shadowLightAlpha),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: context.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: () => onNumberSelected(number),
          child: Stack(
            children: [
              Center(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: context.primaryColor,
                  ),
                  semanticsLabel: label,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonSize * AppConstants.badgeHorizontalPaddingScale,
                      vertical: buttonSize * AppConstants.badgeVerticalPaddingScale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      border: Border.all(
                        color: Colors.white.withAlpha(AppConstants.shadowDarkAlpha),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(AppConstants.shadowMediumAlpha),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: buttonSize * AppConstants.badgeFontScale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
