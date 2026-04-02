/// 应用常量集合
/// 
/// 包含所有应用相关的常量：UI、布局、动画、性能、游戏逻辑等
/// 这是唯一的常量类，替代了原来的 app_constants.dart 和 game_constants.dart
class AppConstants {
  AppConstants._();

  // ==================== 棋盘尺寸常量 ====================
  /// 标准数独棋盘尺寸 (9x9)
  static const int boardSize = 9;

  /// 宫格尺寸 (3x3)
  static const int regionSize = 3;

  /// 默认棋盘尺寸
  static const int defaultBoardSize = 9;

  /// 武士数独棋盘尺寸 (21x21)
  static const int samuraiBoardSize = 21;

  // ==================== 游戏限制常量 ====================
  /// 最大错误次数
  static const int maxMistakes = 3;

  /// 最大历史记录长度
  static const int maxHistorySize = 50;

  /// 记录未完成游戏的最小游戏时长（秒）
  static const int minGameTimeToRecord = 10;

  // ==================== 单元格尺寸常量 ====================
  /// 最小单元格尺寸
  static const double minCellSize = 32.0;

  /// 最大单元格尺寸
  static const double maxCellSize = 64.0;

  /// 棋盘内边距
  static const double boardPadding = 8.0;

  /// 单元格间距
  static const double cellSpacing = 1.0;

  /// 粗线宽度
  static const double thickLineWidth = 2.0;

  /// 细线宽度
  static const double thinLineWidth = 0.5;

  // ==================== UI 尺寸常量 ====================
  /// 默认按钮圆角半径
  static const double defaultBorderRadius = 10.0;

  /// 小按钮圆角半径
  static const double smallBorderRadius = 4.0;

  /// 键盘按钮间距
  static const double keyboardButtonSpacing = 4.0;

  /// 键盘容器内边距
  static const double keyboardPadding = 2.0;

  /// 数字键盘字体缩放比例
  static const double keyboardFontScale = 0.35;

  /// 计数徽章字体缩放比例
  static const double badgeFontScale = 0.25;

  /// 计数徽章水平内边距比例
  static const double badgeHorizontalPaddingScale = 0.06;

  /// 计数徽章垂直内边距比例
  static const double badgeVerticalPaddingScale = 0.03;

  // ==================== 颜色和透明度常量 ====================
  /// 阴影透明度（浅色）
  static const int shadowLightAlpha = 0x33;

  /// 阴影透明度（中等）
  static const int shadowMediumAlpha = 0x66;

  /// 阴影透明度（深色）
  static const int shadowDarkAlpha = 0x99;

  /// 渐变透明度
  static const int gradientAlpha = 0x33;

  // ==================== 动画时长常量 ====================
  /// 默认动画时长（毫秒）
  static const int defaultAnimationDuration = 300;

  /// 快速动画时长（毫秒）
  static const int fastAnimationDuration = 200;

  /// 慢速动画时长（毫秒）
  static const int slowAnimationDuration = 500;

  /// 页面过渡动画时长（毫秒）
  static const int pageTransitionDuration = 400;

  /// 淡入动画时长（毫秒）
  static const int fadeAnimationDuration = 800;

  // ==================== 延迟时间常量 ====================
  /// 自动标记防抖延迟
  static const Duration autoMarkDebounceDelay = Duration(milliseconds: 100);

  /// 批量更新延迟
  static const Duration batchUpdateDelay = Duration(milliseconds: 16);

  /// 保存防抖延迟
  static const Duration saveDebounceDelay = Duration(milliseconds: 500);

  /// 防抖延迟时长（毫秒）
  static const int debounceDurationMs = 16;

  /// 自动保存间隔时长（秒）
  static const int autoSaveIntervalSeconds = 5;

  // ==================== 计时器和超时常量 ====================
  /// 计时器 tick 间隔
  static const Duration timerTickInterval = Duration(seconds: 1);

  /// 加载对话框延迟
  static const Duration loadingDialogDelay = Duration(seconds: 1);

  /// 完成页面短动画延迟
  static const Duration finishScreenShortDelay = Duration(seconds: 1);

  /// 完成页面长动画延迟
  static const Duration finishScreenLongDelay = Duration(seconds: 2);

  /// 提示对话框超时
  static const Duration hintDialogTimeout = Duration(seconds: 5);

  /// 游戏生成超时
  static const Duration generationTimeout = Duration(seconds: 30);

  // ==================== 统计周期常量 ====================
  /// 日统计周期
  static const Duration statsDailyPeriod = Duration(days: 1);

  /// 周统计周期
  static const Duration statsWeeklyPeriod = Duration(days: 7);

  /// 月统计周期
  static const Duration statsMonthlyPeriod = Duration(days: 30);

  /// 年统计周期
  static const Duration statsYearlyPeriod = Duration(days: 365);

  // ==================== 间距常量 ====================
  /// 极小间距 - 用于紧密元素之间
  static const double spacingExtraSmall = 2.0;

  /// 小间距 - 用于组件内元素
  static const double spacingSmall = 4.0;

  /// 中等间距 - 用于相关组件之间
  static const double spacingMedium = 8.0;

  /// 标准间距 - 用于页面布局
  static const double spacingStandard = 12.0;

  /// 大间距 - 用于主要区域分隔
  static const double spacingLarge = 16.0;

  /// 超大间距 - 用于页面顶部和底部
  static const double spacingExtraLarge = 20.0;

  /// 特大间距 - 用于特殊布局
  static const double spacingHuge = 24.0;

  /// 最大间距 - 用于页面主要内容区域
  static const double spacingMaximum = 32.0;

  // ==================== 性能常量 ====================
  /// 最大音效播放器数量
  static const int maxSoundEffectPlayers = 3;

  /// 最大谜题缓存数量
  static const int maxPuzzleCacheSize = 50;

  /// 最大历史记录长度（性能）
  static const int maxHistoryLength = 100;
}

/// 游戏常量别名
/// 
/// 为了向后兼容，提供 GameConstants 作为 AppConstants 的别名
@Deprecated('请使用 AppConstants 替代 GameConstants')
typedef GameConstants = AppConstants;
