import 'package:flutter/material.dart';

/// 屏幕类型枚举
enum DeviceType {
  /// 手机设备
  mobile,
  /// 平板设备
  tablet,
  /// 桌面设备
  desktop,
  /// 大屏桌面设备
  largeDesktop,
}

/// 屏幕类型工具类
/// 
/// 提供屏幕类型检测和响应式计算方法
class ScreenType {
  /// 屏幕类型断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// 判断是否为手机
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为手机设备
  static bool isMobile(final BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < mobileBreakpoint;

  /// 判断是否为平板
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为平板设备
  static bool isTablet(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= mobileBreakpoint &&
        size.shortestSide < tabletBreakpoint;
  }

  /// 判断是否为桌面设备
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为桌面设备
  static bool isDesktop(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= desktopBreakpoint &&
        size.shortestSide < largeDesktopBreakpoint;
  }

  /// 判断是否为大屏桌面设备
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为大屏桌面设备
  static bool isLargeDesktop(final BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= largeDesktopBreakpoint;

  /// 判断是否为大屏幕（平板及以上）
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为大屏幕
  static bool isLargeScreen(final BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= tabletBreakpoint;

  /// 判断是否为竖屏
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为竖屏
  static bool isPortrait(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    if (size.shortestSide < mobileBreakpoint) {
      return orientation == Orientation.portrait;
    }

    return size.height > size.width;
  }

  /// 判断是否为横屏
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回是否为横屏
  static bool isLandscape(final BuildContext context) => !isPortrait(context);

  /// 获取设备类型
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回设备类型
  static DeviceType getDeviceType(final BuildContext context) {
    if (isLargeDesktop(context)) return DeviceType.largeDesktop;
    if (isDesktop(context)) return DeviceType.desktop;
    if (isTablet(context)) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// 获取屏幕类型字符串
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕类型字符串
  static String getScreenType(final BuildContext context) {
    if (isLargeDesktop(context)) return 'large_desktop';
    if (isDesktop(context)) return 'desktop';
    if (isTablet(context)) return 'tablet';
    return 'mobile';
  }

  /// 获取响应式缩放因子
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回响应式缩放因子
  static double getScaleFactor(final BuildContext context) {
    if (isLargeDesktop(context)) return 1.4;
    if (isDesktop(context)) return 1.2;
    if (isTablet(context)) return 1.1;
    return 1.0;
  }

  /// 获取响应式字体大小
  /// 
  /// [context] 构建上下文
  /// [baseSize] 基础字体大小
  /// 
  /// 返回计算后的字体大小
  static double getResponsiveFontSize(
      final BuildContext context, final double baseSize) => baseSize * getScaleFactor(context);

  /// 获取响应式间距
  /// 
  /// [context] 构建上下文
  /// [baseSpacing] 基础间距
  /// 
  /// 返回计算后的间距
  static double getResponsiveSpacing(
      final BuildContext context, final double baseSpacing) => baseSpacing * getScaleFactor(context);

  /// 获取响应式宽度
  /// 
  /// [context] 构建上下文
  /// [baseWidth] 基础宽度
  /// 
  /// 返回计算后的宽度
  static double getResponsiveWidth(
      final BuildContext context, final double baseWidth) => baseWidth * getScaleFactor(context);

  /// 获取响应式高度
  /// 
  /// [context] 构建上下文
  /// [baseHeight] 基础高度
  /// 
  /// 返回计算后的高度
  static double getResponsiveHeight(
      final BuildContext context, final double baseHeight) => baseHeight * getScaleFactor(context);

  /// 获取响应式圆角
  /// 
  /// [context] 构建上下文
  /// [baseRadius] 基础圆角大小
  /// 
  /// 返回计算后的圆角大小
  static double getResponsiveBorderRadius(
      final BuildContext context, final double baseRadius) => baseRadius * getScaleFactor(context);

  /// 获取响应式图标大小
  /// 
  /// [context] 构建上下文
  /// [baseSize] 基础图标大小
  /// 
  /// 返回计算后的图标大小
  static double getResponsiveIconSize(
      final BuildContext context, final double baseSize) => baseSize * getScaleFactor(context);

  /// 获取屏幕宽度
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕宽度
  static double getScreenWidth(final BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// 获取屏幕高度
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕高度
  static double getScreenHeight(final BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// 获取屏幕安全区域
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕安全区域边距
  static EdgeInsets getSafeArea(final BuildContext context) =>
      MediaQuery.of(context).padding;

  /// 获取屏幕可用宽度（减去安全区域）
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕可用宽度
  static double getAvailableWidth(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return size.width - padding.left - padding.right;
  }

  /// 获取屏幕可用高度（减去安全区域）
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕可用高度
  static double getAvailableHeight(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return size.height - padding.top - padding.bottom;
  }
  
  /// 获取屏幕尺寸
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕尺寸
  static Size getScreenSize(final BuildContext context) =>
      MediaQuery.of(context).size;
  
  /// 获取屏幕方向
  /// 
  /// [context] 构建上下文
  /// 
  /// 返回屏幕方向
  static Orientation getOrientation(final BuildContext context) =>
      MediaQuery.of(context).orientation;
}
