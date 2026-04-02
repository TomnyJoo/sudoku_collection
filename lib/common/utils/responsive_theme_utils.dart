import 'package:flutter/material.dart';
import '../layout/screen_type.dart';

/// 响应式主题工具类
///
/// 提供响应式字体大小、间距、组件大小等计算方法
/// 包含缓存机制，避免重复计算，提高性能
class ResponsiveThemeUtils {
  /// 缓存响应式计算结果
  static final Map<String, double> _cache = {};

  /// 生成缓存键
  ///
  /// [prefix] 缓存键前缀，用于区分不同类型的计算
  /// [context] 构建上下文
  /// [baseValue] 基础值
  ///
  /// 返回生成的缓存键
  static String _getCacheKey(
    String prefix,
    BuildContext context,
    double baseValue,
  ) {
    final deviceType = ScreenType.getDeviceType(context);
    return '$prefix${deviceType.index}_$baseValue';
  }

  /// 根据屏幕尺寸计算响应式字体大小
  ///
  /// [context] 构建上下文
  /// [baseSize] 基础字体大小
  ///
  /// 返回计算后的字体大小
  static double getFontSize(BuildContext context, double baseSize) {
    final cacheKey = _getCacheKey('fontSize', context, baseSize);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    final result = ScreenType.getResponsiveFontSize(context, baseSize);
    _cache[cacheKey] = result;
    return result;
  }

  /// 根据屏幕尺寸计算响应式间距
  ///
  /// [context] 构建上下文
  /// [baseSpacing] 基础间距
  ///
  /// 返回计算后的间距
  static double getSpacing(BuildContext context, double baseSpacing) {
    final cacheKey = _getCacheKey('spacing', context, baseSpacing);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    final result = ScreenType.getResponsiveSpacing(context, baseSpacing);
    _cache[cacheKey] = result;
    return result;
  }

  /// 根据屏幕尺寸计算响应式按钮大小
  ///
  /// [context] 构建上下文
  /// [baseWidth] 基础宽度
  /// [baseHeight] 基础高度
  ///
  /// 返回计算后的按钮尺寸
  static Size getButtonSize(
    BuildContext context,
    double baseWidth,
    double baseHeight,
  ) => Size(
    ScreenType.getResponsiveWidth(context, baseWidth),
    ScreenType.getResponsiveHeight(context, baseHeight),
  );

  /// 根据屏幕尺寸计算响应式卡片大小
  ///
  /// [context] 构建上下文
  /// [baseWidth] 基础宽度
  /// [baseHeight] 基础高度
  ///
  /// 返回计算后的卡片尺寸
  static Size getCardSize(
    BuildContext context,
    double baseWidth,
    double baseHeight,
  ) => Size(
    ScreenType.getResponsiveWidth(context, baseWidth),
    ScreenType.getResponsiveHeight(context, baseHeight),
  );

  /// 根据屏幕尺寸计算响应式圆角大小
  ///
  /// [context] 构建上下文
  /// [baseRadius] 基础圆角大小
  ///
  /// 返回计算后的圆角大小
  static double getBorderRadius(BuildContext context, double baseRadius) {
    final cacheKey = _getCacheKey('borderRadius', context, baseRadius);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    final result = ScreenType.getResponsiveBorderRadius(context, baseRadius);
    _cache[cacheKey] = result;
    return result;
  }

  /// 根据屏幕尺寸获取响应式文本样式
  ///
  /// [context] 构建上下文
  /// [baseStyle] 基础文本样式
  ///
  /// 返回计算后的文本样式
  static TextStyle getResponsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final fontSize = getFontSize(context, baseStyle.fontSize ?? 14);
    return baseStyle.copyWith(fontSize: fontSize);
  }

  /// 根据屏幕尺寸获取响应式标题样式
  ///
  /// [context] 构建上下文
  /// [baseStyle] 基础标题样式
  ///
  /// 返回计算后的标题样式
  static TextStyle getResponsiveTitleStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final fontSize = getFontSize(context, baseStyle.fontSize ?? 20);
    return baseStyle.copyWith(fontSize: fontSize);
  }

  /// 根据屏幕尺寸获取响应式图标大小
  ///
  /// [context] 构建上下文
  /// [baseSize] 基础图标大小
  ///
  /// 返回计算后的图标大小
  static double getIconSize(BuildContext context, double baseSize) {
    final cacheKey = _getCacheKey('iconSize', context, baseSize);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    final result = ScreenType.getResponsiveIconSize(context, baseSize);
    _cache[cacheKey] = result;
    return result;
  }

  /// 清除缓存
  ///
  /// 释放缓存内存，建议在应用进入后台或内存不足时调用
  static void clearCache() {
    _cache.clear();
  }

  /// 根据设备类型获取布局列数
  ///
  /// [context] 构建上下文
  ///
  /// 返回适合当前设备的网格列数
  static int getGridColumns(BuildContext context) {
    if (ScreenType.isLargeDesktop(context)) return 4;
    if (ScreenType.isDesktop(context)) return 3;
    if (ScreenType.isTablet(context)) return 2;
    return 1;
  }

  /// 根据设备类型获取列表项高度
  ///
  /// [context] 构建上下文
  /// [baseHeight] 基础高度
  ///
  /// 返回计算后的列表项高度
  static double getListItemHeight(BuildContext context, double baseHeight) =>
      ScreenType.getResponsiveHeight(context, baseHeight);

  /// 根据设备类型获取内容最大宽度
  ///
  /// [context] 构建上下文
  ///
  /// 返回适合当前设备的内容最大宽度
  static double getMaxContentWidth(BuildContext context) {
    if (ScreenType.isLargeDesktop(context)) return 1400;
    if (ScreenType.isDesktop(context)) return 1200;
    if (ScreenType.isTablet(context)) return 900;
    return ScreenType.getScreenWidth(context);
  }

  /// 根据设备类型获取侧边栏宽度
  ///
  /// [context] 构建上下文
  ///
  /// 返回适合当前设备的侧边栏宽度
  static double getSidebarWidth(BuildContext context) {
    if (ScreenType.isLargeDesktop(context)) return 320;
    if (ScreenType.isDesktop(context)) return 280;
    if (ScreenType.isTablet(context)) return 240;
    return 0;
  }

  /// 根据屏幕尺寸计算响应式边距
  ///
  /// [context] 构建上下文
  /// [baseMargin] 基础边距
  ///
  /// 返回计算后的边距
  static double getMargin(BuildContext context, double baseMargin) {
    final cacheKey = _getCacheKey('margin', context, baseMargin);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    final result = ScreenType.getResponsiveSpacing(context, baseMargin);
    _cache[cacheKey] = result;
    return result;
  }

  /// 获取响应式边距 EdgeInsets
  ///
  /// [context] 构建上下文
  /// [horizontal] 水平边距
  /// [vertical] 垂直边距
  ///
  /// 返回计算后的 EdgeInsets
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double horizontal = 16,
    double vertical = 16,
  }) => EdgeInsets.symmetric(
    horizontal: getMargin(context, horizontal),
    vertical: getMargin(context, vertical),
  );
}
