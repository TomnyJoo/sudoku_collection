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
  String get advancedExclusion => '高级排除逻辑';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get appName => '数独';

  @override
  String get autoCheck => '自动检查';

  @override
  String get autoMark => '自动标记';

  @override
  String get autoMarkPossibilities => '自动标记可能值';

  @override
  String get autoSave => '自动保存';

  @override
  String get averageMistakes => '平均错误';

  @override
  String get averageTime => '平均用时';

  @override
  String get backToMenu => '返回';

  @override
  String get basicSettings => '基础设置';

  @override
  String get bestScore => '最佳记录';

  @override
  String get bestScoreRule => '记录规则：用时更短，或用时相同但错误更少';

  @override
  String get bestTime => '最佳用时';

  @override
  String get better => '更好';

  @override
  String get blockExclusion => '区块排除法';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String get clearBestScores => '清除最佳记录';

  @override
  String get clearBoard => '清空棋盘';

  @override
  String get clearBoardConfirm => '确定要清空棋盘吗？';

  @override
  String get clearCell => '清除单元格';

  @override
  String get clearStatistics => '清除统计';

  @override
  String get clearStatisticsConfirmMessage => '确定要清除所有统计数据吗？此操作无法撤销。';

  @override
  String get clearStatisticsConfirmTitle => '确认清除统计';

  @override
  String get combinedStatistics => '综合统计';

  @override
  String get completed => '已完成';

  @override
  String get completedGames => '完成次数';

  @override
  String get completionRate => '完成率';

  @override
  String get confirm => '确认';

  @override
  String get congratulations => '恭喜!';

  @override
  String get current => '当前';

  @override
  String get customDifficulty => '自定义难度';

  @override
  String get customGame => '自定义游戏';

  @override
  String get customGameError => '错误';

  @override
  String get customGameErrorInvalid => '无效棋盘：某些数字相互冲突。';

  @override
  String get customGameErrorMultipleSolutions => '此棋盘有多个解，请添加更多数字。';

  @override
  String get customGameErrorTooFew => '请至少填充17个单元格。';

  @override
  String get customGameInstruction1 => '点击单元格选中它';

  @override
  String get customGameInstruction2 => '使用数字键盘填充数字';

  @override
  String get customGameInstruction3 => '点击相同数字可删除它';

  @override
  String get customGameInstruction4 => '完成后点击\"开始游戏\"';

  @override
  String get customGameInstructions => '自定义游戏说明';

  @override
  String get darkMode => '深色模式';

  @override
  String get daysAgo => '天前';

  @override
  String get difficulty => '难度';

  @override
  String get difficultyBeginner => '入门';

  @override
  String get difficultyCustom => '自定义';

  @override
  String get difficultyDistribution => '难度分布';

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
  String get difficultyPerformance => '难度表现';

  @override
  String get difficultyStatistics => '难度统计';

  @override
  String get efficient => '高效';

  @override
  String get efficientModeDescription => '高效模式：使用预设模板快速生成，质量稳定';

  @override
  String get equalGamesPlayed => '两个游戏玩得一样多';

  @override
  String get erase => '清除';

  @override
  String get error => '错误';

  @override
  String get exportFailed => '导出统计数据失败';

  @override
  String get exportStatistics => '导出统计';

  @override
  String get gameComparison => '游戏对比';

  @override
  String get gameCompletionRate => '游戏完成率';

  @override
  String gameDifficulty(Object level) {
    return '难度: $level';
  }

  @override
  String gameMistakes(Object count) {
    return '错误: $count';
  }

  @override
  String get gameRules => '游戏规则';

  @override
  String get gameSettings => '游戏设置';

  @override
  String gameTime(Object time) {
    return '时间: $time';
  }

  @override
  String get gameTrends => '游戏趋势';

  @override
  String get gameTypeCustomDescription => '完全自定义的数独游戏，可以设置任意规则和区域';

  @override
  String get gameTypeCustomName => '自定义数独';

  @override
  String get gameTypeDiagonalDescription => '除了标准规则外，两条主对角线上的数字也不能重复';

  @override
  String get gameTypeDiagonalName => '对角线数独';

  @override
  String get gameTypeJigsawDescription => '不规则区域的数独游戏，每个不规则区域内的数字不能重复';

  @override
  String get gameTypeJigsawName => '锯齿数独';

  @override
  String get gameTypeKillerDescription => '包含数字和区域，每个区域内的数字之和必须等于指定值';

  @override
  String get gameTypeKillerName => '杀手数独';

  @override
  String get gameTypeSamuraiDescription => '五个标准数独交叉组成的复杂数独游戏';

  @override
  String get gameTypeSamuraiName => '武士数独';

  @override
  String get gameTypeStandardDescription => '经典的9x9数独游戏，每个宫格、每行、每列都不能有重复数字';

  @override
  String get gameTypeStandardName => '标准数独';

  @override
  String get gameTypeWindowDescription => '包含四个3x3窗口区域的数独游戏，窗口区域内的数字也不能重复';

  @override
  String get gameTypeWindowName => '窗口数独';

  @override
  String get generatingGame => '正在生成游戏，请稍候...';

  @override
  String generationFailedError(Object error) {
    return '错误: $error';
  }

  @override
  String get generationFailedMessage => '生成游戏失败，请重试。';

  @override
  String get generationFailedTitle => '生成失败';

  @override
  String get generator => '生成器';

  @override
  String get getHint => '获取提示';

  @override
  String get help => '功能按键';

  @override
  String get hint => '提示';

  @override
  String get hiddenPairsTriples => '隐性数对/三链数排除法';

  @override
  String get hiddenSingles => '隐藏唯一候选数';

  @override
  String get highlightMistakes => '高亮错误';

  @override
  String get home => '首页';

  @override
  String get homeTitle => '数独游戏';

  @override
  String homeVersion(Object version) {
    return '版本 $version';
  }

  @override
  String get hoursAgo => '小时前';

  @override
  String get hybrid => '混合';

  @override
  String get hybridModeDescription => '混合模式：使用预设区域模板，生成随机答案，性能平衡';

  @override
  String get jigsawCustomNotSupported => '锯齿数独暂不支持自定义游戏';

  @override
  String get loadGame => '加载游戏';

  @override
  String get deleteSavedGame => '删除存档';

  @override
  String get deleteSavedGameConfirm => '确定要删除这个存档吗？';

  @override
  String get delete => '删除';

  @override
  String get mark => '标记';

  @override
  String get markCells => '标记单元格';

  @override
  String get minutesAgo => '分钟前';

  @override
  String get mistakes => '错误';

  @override
  String get music => '音乐';

  @override
  String get nakedPairsTriples => '数对/三链数排除法';

  @override
  String get newGame => '新游戏';

  @override
  String get newGameConfirm => '开始新游戏?';

  @override
  String get newGameConfirmContent => '确定要开始新游戏吗？当前进度将会丢失。';

  @override
  String get newRecord => '新纪录！';

  @override
  String get newRecordMessage => '恭喜！你创造了新的最佳记录！';

  @override
  String get noGamesPlayed => '还没有玩过游戏';

  @override
  String get noSavedGame => '未找到存档游戏。';

  @override
  String get noStatistics => '暂无统计数据';

  @override
  String get notCompleted => '未完成';

  @override
  String get ok => '确定';

  @override
  String get okButton => '确定';

  @override
  String get overview => '概览';

  @override
  String get playedMore => ' 玩得更多';

  @override
  String get pleaseWait => '请稍候';

  @override
  String get puzzleCompleted => '数独谜题已完成！';

  @override
  String get random => '随机';

  @override
  String get randomModeDescription => '随机模式：使用回溯算法随机生成，每次都不同';

  @override
  String get recentGames => '最近游戏';

  @override
  String get redo => '重做';

  @override
  String get regionNumbers => '编号';

  @override
  String get reset => '重置';

  @override
  String get resetGame => '重置游戏';

  @override
  String get retry => '重试';

  @override
  String get save => '保存';

  @override
  String get selectDifficulty => '难度选择';

  @override
  String get selectSudokuType => '选择数独类型';

  @override
  String get selectSudokuTypeHint => '请选择一种数独类型';

  @override
  String get settings => '设置';

  @override
  String get settingsAudio => '音频';

  @override
  String get settingsAutoCheck => '自动检查';

  @override
  String get settingsBasicSettings => '基本设置';

  @override
  String get settingsAdvancedStrategies => '高级策略';

  @override
  String get settingsGameSettings => '通用设置';

  @override
  String get settingsGameSettingsTab => '游戏设置';

  @override
  String get settingsHiddenPairsTriples => '隐性数对/三链数排除法';

  @override
  String get settingsHiddenSingles => '隐藏唯一候选数';

  @override
  String get settingsHighlightMistakes => '高亮错误';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsMusic => '音乐';

  @override
  String get settingsNakedPairsTriples => '数对/三链数排除法';

  @override
  String get settingsCandidateSettings => '候选数设置';

  @override
  String get settingsDisplayMode => '显示方式';

  @override
  String get settingsDisplayModeDirect => '直接填入';

  @override
  String get settingsDisplayModeBubble => '气泡提示';

  @override
  String get settingsDisplayModeDialog => '对话框提示';

  @override
  String get settingsHintSettings => '提示设置';

  @override
  String get settingsHintMode => '提示模式';

  @override
  String get settingsHintModeDirect => '直接填入';

  @override
  String get settingsHintModeStrategy => '策略提示';

  @override
  String get settingsHintModeLearning => '学习模式';

  @override
  String get settingsHintModeDetailed => '详细指导';

  @override
  String get settingsHintModeCompleteReasoning => '完整推理';

  @override
  String get settingsUseAdvancedStrategy => '使用高级策略';

  @override
  String get settingsSwordfish => 'Swordfish 排除法';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsXWing => 'X-Wing 排除法';

  @override
  String get showDiagonalLines => '显示对角线';

  @override
  String get showSolution => '显示答案';

  @override
  String get solution => '答案';

  @override
  String get soundEffects => '音效';

  @override
  String get startGame => '开始游戏';

  @override
  String get startNewGame => '新游戏';

  @override
  String get statisticsExported => '统计数据已导出';

  @override
  String get statisticsTitle => '游戏统计';

  @override
  String get summary => '概览';

  @override
  String get sudokuRules => '数独规则';

  @override
  String get swordfish => 'Swordfish 排除法';

  @override
  String get time => '时间';

  @override
  String get totalGames => '总游戏次数';

  @override
  String get undo => '撤销';

  @override
  String get undoRedoOperation => '撤销/重做操作';

  @override
  String get weeklySummary => '本周统计';

  @override
  String get xWing => 'X-Wing 排除法';

  @override
  String get yesterday => '昨天';

  @override
  String get homeCopyright => '版权所有, © 2026 天王软件工作室';

  @override
  String get loading => '正在加载...';

  @override
  String get processing => '正在处理...';

  @override
  String get operationSuccess => '操作成功';

  @override
  String get operationFailed => '操作失败';

  @override
  String get clearAllStatsConfirm => '确定要清除所有游戏类型的统计数据吗？此操作不可恢复。';

  @override
  String get statsCleared => '所有统计数据已清除';

  @override
  String get individualGameStats => '各游戏统计';

  @override
  String get incompleteGames => '未完成游戏';

  @override
  String get consecutiveDays => '连续完成天数';

  @override
  String get longestStreak => '最长连续天数';

  @override
  String get noNumbers => '无数字';

  @override
  String get close => '关闭';

  @override
  String get apply => '应用';

  @override
  String get customSudoku => '自定义数独';

  @override
  String get customSudokuGame => '自定义数独游戏';

  @override
  String cellShouldContain(Object row, Object col, Object value) {
    return '第$row行第$col列应填入$value';
  }

  @override
  String get row => '行';

  @override
  String get col => '列';
}
