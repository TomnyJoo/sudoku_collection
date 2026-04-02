import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';

/// 游戏统计页面
/// 
/// 显示用户的游戏统计数据，包括：
/// - 总览：综合统计数据
/// - 游戏对比：不同游戏类型的对比
/// - 各游戏统计：每种游戏的详细统计
/// - 未完成游戏：未完成的游戏列表
class GameStatisticsScreen extends StatefulWidget {
  const GameStatisticsScreen({super.key});

  @override
  State<GameStatisticsScreen> createState() => _GameStatisticsScreenState();
}

/// 游戏统计页面状态管理
class _GameStatisticsScreenState extends State<GameStatisticsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, GameStatistics> _allStatistics = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await GameStatisticsService.getAllStatistics();
      setState(() {
        _allStatistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showClearAllDialog(BuildContext pageContext) {
    final l10n = AppLocalizations.of(pageContext);
    final scaffoldMessenger = ScaffoldMessenger.of(pageContext);
    return showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.clearStatistics ?? 'Clear Statistics'),
        content: Text(l10n?.clearAllStatsConfirm ?? 'Are you sure you want to clear all game statistics?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await GameStatisticsService.clearAllStatistics();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              // 刷新统计数据
              if (mounted) {
                await _loadAllStatistics();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n?.statsCleared ?? 'All statistics cleared')),
                  );
                }
              }
            },
            child: Text(l10n?.clear ?? 'Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = context.isDarkMode;
    final iconColor = isDarkMode
        ? Colors.white.withAlpha(200)
        : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: iconColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? context.darkBackgroundGradient
                  : [
                      const Color(0xFFF8FAFC),
                      const Color(0xFFE2E8F0),
                      const Color(0xFFCBD5E1),
                    ],
            ),
          ),
        ),
        title: Text(
          l10n?.statisticsTitle ?? 'Statistics',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            onPressed: _loadAllStatistics,
          ),
          PopupMenuButton<String>(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            icon: Icon(Icons.more_vert, color: iconColor),
            onSelected: (String result) async {
              if (result == 'export') {
                await GameStatisticsService.exportAllStatistics();
                // 这里可以实现导出功能，例如复制到剪贴板或保存文件
                if (mounted) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(SnackBar(content: Text(l10n?.statisticsExported ?? 'Statistics exported')));
                }
              } else if (result == 'clearAll') {
                if (mounted) {
                  await _showClearAllDialog(context);
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'export',
                child: Text(l10n?.exportStatistics ?? 'Export Statistics'),
              ),
              PopupMenuItem<String>(
                value: 'clearAll',
                child: Text(l10n?.clearStatistics ?? 'Clear Statistics'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDarkMode ? Colors.white : AppColors.darkText,
          unselectedLabelColor: isDarkMode
              ? Colors.white70
              : AppColors.mutedText,
          indicatorColor: isDarkMode ? Colors.white : AppColors.buttonPrimary,
          tabs: [
            Tab(text: l10n?.overview ?? 'Overview'),
            Tab(text: l10n?.gameComparison ?? 'Comparison'),
            Tab(text: l10n?.individualGameStats ?? 'Individual Games'),
            Tab(text: l10n?.incompleteGames ?? 'Incomplete'),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? null : AppColors.homeLightBackground,
          gradient: isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.darkBackgroundGradient,
                )
              : null,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    OverviewTab(allStatistics: _allStatistics),
                    GameComparisonTab(allStatistics: _allStatistics),
                    IndividualGamesTab(allStatistics: _allStatistics),
                    IncompleteGamesTab(allStatistics: _allStatistics),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 总览标签页状态管理
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.allStatistics});
  final Map<String, GameStatistics> allStatistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalGames = allStatistics.values.fold<int>(
      0,
      (sum, s) => sum + s.totalGames,
    );

    if (totalGames == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n?.noStatistics ?? 'No statistics available',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final completedGames = allStatistics.values.fold<int>(
      0,
      (sum, s) => sum + s.completedGames,
    );
    final totalTime = allStatistics.values.fold<int>(
      0,
      (sum, s) => sum + s.averageTime * s.completedGames,
    );
    final avgTime = completedGames > 0 ? totalTime ~/ completedGames : 0;
    final completionRate = totalGames > 0
        ? (completedGames / totalGames * 100).toStringAsFixed(1)
        : '0.0';
    final bestTime = allStatistics.values
        .where((s) => s.bestTime > 0)
        .fold<int>(
          0,
          (min, s) => min == 0 || s.bestTime < min ? s.bestTime : min,
        );
    final totalMistakes = allStatistics.values.fold<int>(
      0,
      (sum, s) => sum + (s.averageMistakes * s.completedGames).round(),
    );
    final avgMistakes = completedGames > 0
        ? totalMistakes / completedGames
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallSummaryCard(
            context,
            totalGames,
            completedGames,
            completionRate,
            avgTime,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(context, bestTime, avgMistakes, allStatistics),
        ],
      ),
    );
  }

  Widget _buildOverallSummaryCard(
    BuildContext context,
    int totalGames,
    int completedGames,
    String completionRate,
    int avgTime,
  ) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.overview ?? 'Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.totalGames ?? 'Total Games',
                    totalGames.toString(),
                    Icons.games,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.completedGames ?? 'Completed',
                    completedGames.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.completionRate ?? 'Completion Rate',
                    '$completionRate%',
                    Icons.pie_chart,
                    AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.averageTime ?? 'Average Time',
                    _formatTime(avgTime),
                    Icons.timer,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    int bestTime,
    double avgMistakes,
    Map<String, GameStatistics> allStatistics,
  ) {
    final l10n = AppLocalizations.of(context);
    final activeGameTypes = allStatistics.values
        .where((s) => s.totalGames > 0)
        .length;

    // 计算连续天数和最长连续天数
    int maxConsecutiveDays = 0;
    int maxLongestStreak = 0;
    for (final stats in allStatistics.values) {
      if (stats.consecutiveDays > maxConsecutiveDays) {
        maxConsecutiveDays = stats.consecutiveDays;
      }
      if (stats.longestStreak > maxLongestStreak) {
        maxLongestStreak = stats.longestStreak;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.summary ?? 'Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              context,
              l10n?.bestTime ?? 'Best Time Overall',
              bestTime > 0 ? _formatTime(bestTime) : '--',
              Icons.emoji_events,
            ),
            const Divider(),
            _buildDetailItem(
              context,
              l10n?.averageMistakes ?? 'Average Mistakes',
              avgMistakes.toStringAsFixed(1),
              Icons.error_outline,
            ),
            const Divider(),
            _buildDetailItem(
              context,
              l10n?.activeGameTypes ?? 'Active Game Types',
              activeGameTypes.toString(),
              Icons.category,
            ),
            const Divider(),
            _buildDetailItem(
              context,
              l10n?.consecutiveDays ?? 'Consecutive Days',
              maxConsecutiveDays.toString(),
              Icons.calendar_today,
            ),
            const Divider(),
            _buildDetailItem(
              context,
              l10n?.longestStreak ?? 'Longest Streak',
              maxLongestStreak.toString(),
              Icons.local_fire_department,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Column(
    children: [
      Icon(icon, size: 32, color: color),
      const SizedBox(height: 8),
      Text(
        value,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

/// 游戏比较标签页状态管理
class GameComparisonTab extends StatelessWidget {
  const GameComparisonTab({super.key, required this.allStatistics});
  final Map<String, GameStatistics> allStatistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gameTypes = [
      'standard',
      'jigsaw',
      'diagonal',
      'killer',
      'window',
      'samurai',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.gameComparison ?? 'Game Comparison',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...gameTypes.map((type) {
                final stats = allStatistics[type];
                if (stats == null || stats.totalGames == 0) {
                  return const SizedBox.shrink();
                }
                return _buildGameComparisonItem(context, type, stats, l10n);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameComparisonItem(
    BuildContext context,
    String gameType,
    GameStatistics stats,
    AppLocalizations? l10n,
  ) {
    final completionRate = stats.totalGames > 0
        ? (stats.completedGames / stats.totalGames * 100).toStringAsFixed(1)
        : '0.0';

    String gameName;
    switch (gameType) {
      case 'standard':
        gameName = l10n?.gameTypeStandardName ?? 'Standard';
        break;
      case 'jigsaw':
        gameName = l10n?.gameTypeJigsawName ?? 'Jigsaw';
        break;
      case 'diagonal':
        gameName = l10n?.gameTypeDiagonalName ?? 'Diagonal';
        break;
      case 'killer':
        gameName = l10n?.gameTypeKillerName ?? 'Killer';
        break;
      case 'window':
        gameName = l10n?.gameTypeWindowName ?? 'Window';
        break;
      case 'samurai':
        gameName = l10n?.gameTypeSamuraiName ?? 'Samurai';
        break;
      default:
        gameName = gameType;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gameName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${stats.completedGames}/${stats.totalGames}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: stats.totalGames > 0
                ? stats.completedGames / stats.totalGames
                : 0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(stats.completionRate),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n?.completionRate ?? 'Completion'}: $completionRate%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${l10n?.averageTime ?? 'Avg Time'}: ${_formatTime(stats.averageTime)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 50) return AppColors.orange;
    return AppColors.error;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

/// 个体游戏标签页状态管理
class IndividualGamesTab extends StatelessWidget {
  const IndividualGamesTab({super.key, required this.allStatistics});
  final Map<String, GameStatistics> allStatistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gameTypes = [
      'standard',
      'jigsaw',
      'diagonal',
      'killer',
      'window',
      'samurai',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: gameTypes.map((type) {
          final stats = allStatistics[type];
          if (stats == null || stats.totalGames == 0) {
            return const SizedBox.shrink();
          }
          return _buildGameStatisticsCard(context, type, stats, l10n);
        }).toList(),
      ),
    );
  }

  Widget _buildGameStatisticsCard(
    BuildContext context,
    String gameType,
    GameStatistics stats,
    AppLocalizations? l10n,
  ) {
    String gameName;
    switch (gameType) {
      case 'standard':
        gameName = l10n?.gameTypeStandardName ?? 'Standard';
        break;
      case 'jigsaw':
        gameName = l10n?.gameTypeJigsawName ?? 'Jigsaw';
        break;
      case 'diagonal':
        gameName = l10n?.gameTypeDiagonalName ?? 'Diagonal';
        break;
      case 'killer':
        gameName = l10n?.gameTypeKillerName ?? 'Killer';
        break;
      case 'window':
        gameName = l10n?.gameTypeWindowName ?? 'Window';
        break;
      case 'samurai':
        gameName = l10n?.gameTypeSamuraiName ?? 'Samurai';
        break;
      default:
        gameName = gameType;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearDialog(context, gameType),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.totalGames ?? 'Total Games',
                    stats.totalGames.toString(),
                    Icons.games,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.completedGames ?? 'Completed',
                    stats.completedGames.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.completionRate ?? 'Completion Rate',
                    '${stats.completionRate.toStringAsFixed(1)}%',
                    Icons.pie_chart,
                    AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n?.averageTime ?? 'Average Time',
                    _formatTime(stats.averageTime),
                    Icons.timer,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.difficultyStats.isNotEmpty) ...[
              Text(
                '难度统计',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stats.difficultyStats.entries.map((entry) {
                final difficulty = entry.key;
                final difficultyStats = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDifficultyName(difficulty, l10n),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: difficultyStats.totalGames > 0
                            ? difficultyStats.completedGames /
                                  difficultyStats.totalGames
                            : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(difficultyStats.completionRate),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${difficultyStats.completedGames}/${difficultyStats.totalGames} - ${_formatTime(difficultyStats.averageTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }),
            ],

            // 推荐难度
            if (stats.recommendedDifficulty.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '推荐难度',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getDifficultyName(stats.recommendedDifficulty, l10n),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            // 时间分布
            if (stats.timeDistribution.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '时间分布',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stats.timeDistribution.entries.map((entry) {
                final range = entry.key;
                final count = entry.value;
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(range, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        '$count 局',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }),
            ],

            // 错误模式
            if (stats.errorPatterns.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '常见错误',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: stats.errorPatterns.entries.map((entry) {
                  final number = entry.key;
                  final count = entry.value;
                  return Chip(
                    label: Text('$number ($count)'),
                    backgroundColor: AppColors.error.withAlpha(20),
                    labelStyle: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showClearDialog(BuildContext context, String gameType) {
    final l10n = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.clearStatistics ?? 'Clear Statistics'),
        content: const Text('确定要清除此游戏类型的所有统计数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await GameStatisticsService.clearStatistics(gameType);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              // Refresh the parent widget
              if (context.mounted) {
                // Trigger a refresh
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const GameStatisticsScreen(),
                  ),
                );
              }
            },
            child: Text(l10n?.clear ?? 'Clear'),
          ),
        ],
      ),
    );
  }

  String _getDifficultyName(String difficulty, AppLocalizations? l10n) {
    switch (difficulty) {
      case 'beginner':
        return l10n?.difficultyBeginner ?? 'Beginner';
      case 'easy':
        return l10n?.difficultyEasy ?? 'Easy';
      case 'medium':
        return l10n?.difficultyMedium ?? 'Medium';
      case 'hard':
        return l10n?.difficultyHard ?? 'Hard';
      case 'expert':
        return l10n?.difficultyExpert ?? 'Expert';
      case 'master':
        return l10n?.difficultyMaster ?? 'Master';
      default:
        return difficulty;
    }
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Column(
    children: [
      Icon(icon, size: 24, color: color),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );

  Color _getProgressColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 50) return AppColors.orange;
    return AppColors.error;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

/// 未完成游戏标签页状态管理
class IncompleteGamesTab extends StatelessWidget {
  const IncompleteGamesTab({super.key, required this.allStatistics});
  final Map<String, GameStatistics> allStatistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final incompleteGames = _getIncompleteGames();

    if (incompleteGames.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.incomplete_circle, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '没有未完成的游戏',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: incompleteGames
            .map(
              (game) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getGameName(game.gameType, l10n),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${game.completionPercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_getDifficultyName(game.difficulty, l10n)} · ${_formatTime(game.time)} · ${game.mistakes} ${l10n?.mistakes ?? 'mistakes'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: game.completionPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '开始时间: ${game.timestamp.year}-${game.timestamp.month.toString().padLeft(2, '0')}-${game.timestamp.day.toString().padLeft(2, '0')} ${game.timestamp.hour.toString().padLeft(2, '0')}:${game.timestamp.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<GameRecord> _getIncompleteGames() {
    final incompleteGames = <GameRecord>[];
    for (final stats in allStatistics.values) {
      incompleteGames.addAll(
        stats.recentGames.where((game) => !game.isCompleted),
      );
    }
    incompleteGames.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return incompleteGames;
  }

  String _getGameName(String gameType, AppLocalizations? l10n) {
    switch (gameType) {
      case 'standard':
        return l10n?.gameTypeStandardName ?? 'Standard';
      case 'jigsaw':
        return l10n?.gameTypeJigsawName ?? 'Jigsaw';
      case 'diagonal':
        return l10n?.gameTypeDiagonalName ?? 'Diagonal';
      case 'killer':
        return l10n?.gameTypeKillerName ?? 'Killer';
      case 'window':
        return l10n?.gameTypeWindowName ?? 'Window';
      case 'samurai':
        return l10n?.gameTypeSamuraiName ?? 'Samurai';
      default:
        return gameType;
    }
  }

  String _getDifficultyName(String difficulty, AppLocalizations? l10n) {
    switch (difficulty) {
      case 'beginner':
        return l10n?.difficultyBeginner ?? 'Beginner';
      case 'easy':
        return l10n?.difficultyEasy ?? 'Easy';
      case 'medium':
        return l10n?.difficultyMedium ?? 'Medium';
      case 'hard':
        return l10n?.difficultyHard ?? 'Hard';
      case 'expert':
        return l10n?.difficultyExpert ?? 'Expert';
      case 'master':
        return l10n?.difficultyMaster ?? 'Master';
      default:
        return difficulty;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
