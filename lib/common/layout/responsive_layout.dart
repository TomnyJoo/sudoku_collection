import 'package:flutter/material.dart';
import 'package:sudoku/common/layout/screen_type.dart';

/// 增强的响应式布局工具类
class ResponsiveLayout {
  // 缓存布局计算结果
  static final Map<String, dynamic> _layoutCache = {};

  /// 清除布局缓存
  static void clearCache() {
    _layoutCache.clear();
  }

  /// 获取响应式边距（基于屏幕类型和方向）
  static double getResponsivePadding(final BuildContext context) {
    final cacheKey =
        'padding_${ScreenType.getScreenType(context)}_${ScreenType.isPortrait(context)}';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);
    final isPortrait = ScreenType.isPortrait(context);

    double padding;
    switch (screenType) {
      case 'desktop':
        padding = 48;
        break;
      case 'tablet':
        padding = isPortrait ? 32.0 : 24.0;
        break;
      default: // mobile
        padding = isPortrait ? 20.0 : 16.0;
        break;
    }

    _layoutCache[cacheKey] = padding;
    return padding;
  }

  /// 获取响应式间距（组件间间距）
  static double getResponsiveSpacing(final BuildContext context) {
    final cacheKey =
        'spacing_${ScreenType.getScreenType(context)}_${ScreenType.isPortrait(context)}';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);
    final isPortrait = ScreenType.isPortrait(context);

    double spacing;
    switch (screenType) {
      case 'desktop':
        spacing = 32;
        break;
      case 'tablet':
        spacing = isPortrait ? 24.0 : 20.0;
        break;
      default: // mobile
        spacing = isPortrait ? 16.0 : 12.0;
        break;
    }

    _layoutCache[cacheKey] = spacing;
    return spacing;
  }

  /// 获取响应式字体大小（考虑屏幕方向和密度）
  static double getResponsiveFontSize(
    final double baseSize,
    final BuildContext context,
  ) {
    final cacheKey =
        'font_${ScreenType.getScreenType(context)}_${ScreenType.isPortrait(context)}_${MediaQuery.of(context).devicePixelRatio}_$baseSize';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);
    final isPortrait = ScreenType.isPortrait(context);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    var scaleFactor = 1.0;

    switch (screenType) {
      case 'desktop':
        scaleFactor = 1.4;
        break;
      case 'tablet':
        scaleFactor = isPortrait ? 1.2 : 1.1;
        break;
      default: // mobile
        scaleFactor = isPortrait ? 1.0 : 0.95;
        break;
    }

    // 考虑像素密度
    if (pixelRatio > 2.5) {
      scaleFactor *= 0.9; // 高密度屏幕适当减小字体
    }

    final fontSize = (baseSize * scaleFactor).clamp(
      baseSize * 0.8,
      baseSize * 1.5,
    );
    _layoutCache[cacheKey] = fontSize;
    return fontSize;
  }

  /// 获取响应式按钮尺寸
  static Size getResponsiveButtonSize(final BuildContext context) {
    final cacheKey =
        'button_${ScreenType.getScreenType(context)}_${ScreenType.isPortrait(context)}_${MediaQuery.of(context).size.width}';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);
    final isPortrait = ScreenType.isPortrait(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double buttonWidth;
    double buttonHeight;

    switch (screenType) {
      case 'desktop':
        buttonWidth = isPortrait ? screenWidth * 0.4 : screenWidth * 0.3;
        buttonHeight = isPortrait ? 80.0 : 70.0;
        break;
      case 'tablet':
        buttonWidth = isPortrait ? screenWidth * 0.5 : screenWidth * 0.35;
        buttonHeight = isPortrait ? 75.0 : 65.0;
        break;
      default: // mobile
        buttonWidth = isPortrait ? screenWidth * 0.7 : screenWidth * 0.5;
        buttonHeight = isPortrait ? 65.0 : 55.0;
        break;
    }

    // 设置最小和最大宽度限制
    var minWidth = 200.0;
    var maxWidth = 400.0;

    switch (screenType) {
      case 'desktop':
        minWidth = 250.0;
        maxWidth = 500.0;
        break;
      case 'tablet':
        minWidth = 220.0;
        maxWidth = 450.0;
        break;
    }

    buttonWidth = buttonWidth.clamp(minWidth, maxWidth);

    final size = Size(buttonWidth, buttonHeight);
    _layoutCache[cacheKey] = size;
    return size;
  }

  /// 计算棋盘尺寸（增强版）
  static double calculateBoardSize(
    final BoxConstraints constraints,
    final BuildContext context, {
    double maxWidthFactor = 0.9,
    double maxHeightFactor = 0.8,
  }) {
    final cacheKey =
        'board_${ScreenType.getScreenType(context)}_'
        '${ScreenType.isPortrait(context)}_${constraints.maxWidth}'
        '_${constraints.maxHeight}_${maxWidthFactor}_$maxHeightFactor';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);
    final isPortrait = ScreenType.isPortrait(context);

    final double availableWidth = constraints.maxWidth;
    final double availableHeight = constraints.maxHeight;

    // 根据设备类型调整因子
    double widthFactor = maxWidthFactor;
    double heightFactor = maxHeightFactor;

    switch (screenType) {
      case 'desktop':
        widthFactor = isPortrait ? 0.7 : 0.6;
        heightFactor = isPortrait ? 0.6 : 0.7;
        break;
      case 'tablet':
        widthFactor = isPortrait ? 0.8 : 0.7;
        heightFactor = isPortrait ? 0.7 : 0.8;
        break;
      default: // mobile
        widthFactor = isPortrait ? 0.9 : 0.8;
        heightFactor = isPortrait ? 0.8 : 0.9;
        break;
    }

    final widthBasedSize = availableWidth * widthFactor;
    final heightBasedSize = availableHeight * heightFactor;

    final double calculatedSize = widthBasedSize < heightBasedSize
        ? widthBasedSize
        : heightBasedSize;

    // 设置最小和最大尺寸限制
    var minSize = 200.0;
    var maxSize = 600.0;

    switch (screenType) {
      case 'desktop':
        minSize = 300.0;
        maxSize = 800.0;
        break;
      case 'tablet':
        minSize = 250.0;
        maxSize = 700.0;
        break;
    }

    final size = calculatedSize.clamp(minSize, maxSize);
    _layoutCache[cacheKey] = size;
    return size;
  }

  /// 获取响应式图标尺寸
  static double getResponsiveIconSize(final BuildContext context) {
    final cacheKey = 'icon_${ScreenType.getScreenType(context)}';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);

    double size;
    switch (screenType) {
      case 'desktop':
        size = 32;
        break;
      case 'tablet':
        size = 28;
        break;
      default: // mobile
        size = 24;
        break;
    }

    _layoutCache[cacheKey] = size;
    return size;
  }

  /// 获取响应式卡片圆角
  static double getResponsiveBorderRadius(final BuildContext context) {
    final cacheKey = 'radius_${ScreenType.getScreenType(context)}';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);

    double radius;
    switch (screenType) {
      case 'desktop':
        radius = 24;
        break;
      case 'tablet':
        radius = 20;
        break;
      default: // mobile
        radius = 16;
        break;
    }

    _layoutCache[cacheKey] = radius;
    return radius;
  }

  /// 获取响应式阴影模糊半径
  static double getResponsiveShadowBlur(final BuildContext context) {
    final cacheKey = 'shadow_${ScreenType.getScreenType(context)}';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);

    double blur;
    switch (screenType) {
      case 'desktop':
        blur = 16;
        break;
      case 'tablet':
        blur = 12;
        break;
      default: // mobile
        blur = 8;
        break;
    }

    _layoutCache[cacheKey] = blur;
    return blur;
  }

  /// 判断是否为平板竖屏模式（特殊处理）
  static bool isTabletPortrait(final BuildContext context) =>
      ScreenType.isTablet(context) && ScreenType.isPortrait(context);

  /// 判断是否为平板横屏模式（特殊处理）
  static bool isTabletLandscape(final BuildContext context) =>
      ScreenType.isTablet(context) && ScreenType.isLandscape(context);

  /// 获取屏幕安全区域边距
  static EdgeInsets getSafeAreaInsets(final BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  /// 获取键盘高度（考虑安全区域）
  static double getKeyboardHeight(
    final BuildContext context, {
    final double baseHeight = 200,
  }) {
    final cacheKey =
        'keyboard_${ScreenType.getScreenType(context)}_${ScreenType.isPortrait(context)}_$baseHeight';

    if (_layoutCache.containsKey(cacheKey)) {
      return _layoutCache[cacheKey];
    }

    final screenType = ScreenType.getScreenType(context);
    final isPortrait = ScreenType.isPortrait(context);

    double height;
    switch (screenType) {
      case 'desktop':
        height = baseHeight * 1.2;
        break;
      case 'tablet':
        height = isPortrait ? baseHeight * 1.1 : baseHeight * 0.9;
        break;
      default: // mobile
        height = isPortrait ? baseHeight : baseHeight * 0.8;
        break;
    }

    _layoutCache[cacheKey] = height;
    return height;
  }
}
