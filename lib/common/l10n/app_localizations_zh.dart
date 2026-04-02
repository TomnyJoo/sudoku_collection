// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get activeGameTypes => '活跃游戏类型';

  @override
  String get appName => '数独';

  @override
  String get autoMark => '自动标记';

  @override
  String get averageMistakes => '平均错误数';

  @override
  String get averageTime => '平均时间';

  @override
  String get backToMenu => '返回菜单';

  @override
  String get bestScore => '最佳分数';

  @override
  String get bestTime => '最佳时间';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清空';

  @override
  String get clearAllStatsConfirm => '确定要清空所有统计数据吗？';

  @override
  String get clearBoard => '清空棋盘';

  @override
  String get clearBoardConfirm => '确定要清空棋盘吗？';

  @override
  String get clearStatistics => '清空统计';

  @override
  String get completedGames => '已完成游戏';

  @override
  String get completionRate => '完成率';

  @override
  String get confirm => '确认';

  @override
  String get congratulations => '恭喜！';

  @override
  String get consecutiveDays => '连续天数';

  @override
  String get current => '当前';

  @override
  String get customGame => '自定义游戏';

  @override
  String get customGameError => '创建自定义游戏时出错';

  @override
  String get customGameErrorInvalid => '无效的数独，请检查你的输入。';

  @override
  String get customGameErrorMultipleSolutions => '这个数独有多个解决方案。';

  @override
  String get customGameErrorTooFew => '输入的数字太少，请添加更多。';

  @override
  String get customGameInstruction1 => '在网格中输入 1-9 的数字。';

  @override
  String get customGameInstruction2 => '留下空单元格让 puzzle 解决。';

  @override
  String get customSudoku => '自定义数独';

  @override
  String get difficulty => '难度';

  @override
  String get difficultyBeginner => '初学者';

  @override
  String get difficultyCustom => '自定义';

  @override
  String get difficultyEasy => '简单';

  @override
  String get difficultyExpert => '专家';

  @override
  String get difficultyHard => '困难';

  @override
  String get difficultyMaster => '大师';

  @override
  String get difficultyMedium => '中等';

  @override
  String get erase => '擦除';

  @override
  String get error => '错误';

  @override
  String get exportStatistics => '导出统计';

  @override
  String get gameComparison => '游戏比较';

  @override
  String get gameRules => '游戏规则';

  @override
  String get gameTypeDiagonalDescription => '除标准规则外，两条主对角线上的数字也不能重复';

  @override
  String get gameTypeDiagonalName => '对角线数独';

  @override
  String get gameTypeJigsawDescription => '一种数独游戏，具有不规则区域，每个区域内的数字不能重复';

  @override
  String get gameTypeJigsawName => '锯齿数独';

  @override
  String get gameTypeKillerDescription => '包含数字和区域，每个区域内数字的和必须等于指定值';

  @override
  String get gameTypeKillerName => '杀手数独';

  @override
  String get gameTypeSamuraiDescription => '由五个标准数独 puzzle 相交组成的复杂数独游戏';

  @override
  String get gameTypeSamuraiName => '武士数独';

  @override
  String get gameTypeStandardDescription =>
      '经典 9x9 数独游戏，每行、每列和每个 3x3 区块必须包含数字 1-9，不重复';

  @override
  String get gameTypeStandardName => '标准数独';

  @override
  String get gameTypeWindowDescription => '一种数独游戏，有四个 3x3 窗口区域，窗口区域内的数字不能重复';

  @override
  String get gameTypeWindowName => '窗口数独';

  @override
  String get generatingGame => '正在生成游戏，请稍候...';

  @override
  String generationFailedError(Object error) {
    return '错误：$error';
  }

  @override
  String get generationFailedMessage => '生成游戏失败，请重试。';

  @override
  String get generationFailedTitle => '生成失败';

  @override
  String get hint => '提示';

  @override
  String get homeCopyright => '© 2026 Topking Software';

  @override
  String homeVersion(Object version) {
    return '版本 $version';
  }

  @override
  String get incompleteGames => '未完成游戏';

  @override
  String get individualGameStats => '个人游戏统计';

  @override
  String get loadGame => '加载游戏';

  @override
  String get loading => '加载中...';

  @override
  String get longestStreak => '最长连续记录';

  @override
  String get mark => '标记';

  @override
  String get mistakes => '错误';

  @override
  String get newGame => '新游戏';

  @override
  String get newGameConfirm => '开始新游戏？';

  @override
  String get newGameConfirmContent => '确定要开始新游戏吗？当前进度将丢失。';

  @override
  String get newRecord => '新记录！';

  @override
  String get newRecordMessage => '你创造了新记录！';

  @override
  String get noStatistics => '暂无统计数据';

  @override
  String get ok => '确定';

  @override
  String get okButton => '确定';

  @override
  String get operationFailed => '操作失败';

  @override
  String get operationSuccess => '操作成功';

  @override
  String get overview => '概览';

  @override
  String get processing => '处理中...';

  @override
  String get puzzleCompleted => ' puzzle 完成';

  @override
  String get redo => '重做';

  @override
  String get reset => '重置';

  @override
  String get selectDifficulty => '选择难度';

  @override
  String get selectSudokuType => '选择数独类型';

  @override
  String get selectSudokuTypeHint => '请选择数独类型';

  @override
  String get settingsAudio => '音频';

  @override
  String get settingsAutoCheck => '自动检查';

  @override
  String get settingsBasicSettings => '基本设置';

  @override
  String get settingsCandidateSettings => '候选数设置';

  @override
  String get settingsGameSettings => '游戏设置';

  @override
  String get settingsGameSettingsTab => '游戏设置';

  @override
  String get settingsHighlightMistakes => '高亮错误';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsMusic => '音乐';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsUseAdvancedStrategy => '使用高级策略';

  @override
  String get solution => '解决方案';

  @override
  String get soundEffects => '音效';

  @override
  String get startNewGame => '开始新游戏';

  @override
  String get statisticsExported => '统计数据已成功导出';

  @override
  String get statisticsTitle => '统计';

  @override
  String get statsCleared => '统计数据已成功清空';

  @override
  String get summary => '总结';

  @override
  String get time => '时间';

  @override
  String get totalGames => '总游戏数';

  @override
  String get undo => '撤销';
}
