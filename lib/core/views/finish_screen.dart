import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

/// 通用完成页面模板基类（泛型版本）
///
/// 严格遵循标准数独的布局实现
/// 提供游戏完成时的统计展示和操作按钮
/// 
/// 类型参数：
/// - T: GameViewModel 的具体类型
/// - S: GameService 的具体类型
abstract class FinishScreenTemplate<T extends GameViewModel, S extends GameService> extends StatefulWidget {
  const FinishScreenTemplate({super.key});

  @override
  State<FinishScreenTemplate<T, S>> createState() => FinishScreenTemplateState<T, S>();

  /// 游戏类型标识（如 'standard', 'diagonal', 'samurai' 等）
  @protected
  String get gameType;

  /// 获取 ViewModel（子类实现）
  @protected
  T getViewModel(BuildContext context);

  /// 获取 Service（子类实现或依赖注入）
  @protected
  S get gameService;

  /// 获取游戏状态
  @protected
  GameState getGameState(BuildContext context) => getViewModel(context).state;

  /// 获取已消耗时间（默认实现，子类可重写）
  @protected
  int getElapsedTime(BuildContext context) => getGameState(context).elapsedTime;

  /// 获取错误次数（默认实现，子类可重写）
  @protected
  int getMistakes(BuildContext context) => getGameState(context).mistakes;

  /// 获取当前难度（默认实现，子类可重写）
  @protected
  String getCurrentDifficulty(BuildContext context) => getGameState(context).difficulty;

  /// 获取本地化难度名称（默认实现，子类可重写）
  @protected
  String getLocalizedDifficulty(BuildContext context) => getViewModel(context).getLocalizedDifficulty(context);

  /// 保存最佳成绩（默认实现，子类可重写）
  @protected
  Future<bool> saveBestScore(BuildContext context) async {
    final state = getGameState(context);
    return gameService.saveBestScore(
      difficulty: state.difficulty,
      timeInSeconds: state.elapsedTime,
      mistakes: state.mistakes,
    );
  }

  /// 保存游戏统计记录（默认实现，子类可重写）
  @protected
  Future<void> saveGameStatistics(BuildContext context) async {
    final state = getGameState(context);
    await GameStatisticsService.addGameRecord(
      gameType: gameType,
      difficulty: state.difficulty,
      isCompleted: true,
      time: state.elapsedTime,
      mistakes: state.mistakes,
    );
  }

  /// 清除保存的游戏（默认实现，子类可重写）
  @protected
  Future<void> clearSavedGame(BuildContext context) async {
    await gameService.deleteGameState('${gameType}_current');
  }

  /// 加载最佳成绩（默认实现，子类可重写）
  @protected
  Future<Map<String, dynamic>> loadBestScores(BuildContext context) async {
    try {
      final scores = await gameService.getBestScores();
      // 确保返回的是 Map<String, dynamic>
      return Map<String, dynamic>.from(scores);
    } catch (e) {
      // 加载失败时返回空 Map
      return {};
    }
  }

  /// 开始新游戏（默认实现，子类可重写）
  @protected
  Future<void> startNewGame(BuildContext context) async {
    final viewModel = getViewModel(context);
    final difficulty = getCurrentDifficulty(context);
    await gameService.deleteGameState('${gameType}_current');
    await viewModel.startNewGame(DifficultyExtension.fromIdentifier(difficulty));
  }

  /// 导航到游戏页面（默认实现，子类可重写）
  @protected
  void navigateToGameScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/${gameType}_game');
  }

  /// 导航到主页（默认实现，子类可重写）
  @protected
  void navigateToHomeScreen(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  // ========== 工具方法（通常不需要重写） ==========

  @protected
  String formatTime(int seconds) => GameUtils.formatTime(seconds);

  @protected
  dynamic getBestScore(BuildContext context, String difficulty) => null;

  @protected
  String getBestScoreTime(BuildContext context, dynamic bestScore) {
    if (bestScore is Map<String, dynamic>) {
      final time = bestScore['time'] as int?;
      if (time != null) {
        return formatTime(time);
      }
    }
    return '--:--';
  }

  /// 获取最佳成绩的时间值（秒），用于比较
  @protected
  int? getBestScoreTimeValue(BuildContext context, dynamic bestScore) {
    if (bestScore is Map<String, dynamic>) {
      return bestScore['time'] as int?;
    }
    return null;
  }

  @protected
  int getBestScoreMistakes(BuildContext context, dynamic bestScore) {
    if (bestScore is Map<String, dynamic>) {
      return bestScore['mistakes'] as int? ?? 0;
    }
    return 0;
  }

  @protected
  String? getProgressText(dynamic generationStage) =>
      GameUtils.getProgressText(generationStage);

  @protected
  Difficulty? getDifficultyFromIdentifier(String identifier) =>
      GameUtils.getDifficultyFromIdentifier(identifier);

  @protected
  bool isGenerating(BuildContext context) {
    final viewModel = getViewModel(context);
    return viewModel.isLoading;
  }
}

class FinishScreenTemplateState<T extends GameViewModel, S extends GameService> extends State<FinishScreenTemplate<T, S>> with TickerProviderStateMixin {
  Map<String, dynamic> _bestScores = {};
  bool _hasShownDialog = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _confettiController;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _loadBestScoresAndSave();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: GameConstants.finishScreenShortDelay,
      vsync: this,
    );
    
    // 创建缩放动画
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceOut,
      ),
    );
    
    // 初始化五彩纸屑动画控制器
    _confettiController = AnimationController(
      duration: GameConstants.finishScreenLongDelay,
      vsync: this,
    );
    
    _confettiAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _confettiController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 启动动画
    _animationController.forward();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadBestScoresAndSave() async {
    if (!mounted) return;

    // 获取当前成绩
    final currentTime = widget.getElapsedTime(context);
    final currentMistakes = widget.getMistakes(context);
    final currentDifficulty = widget.getCurrentDifficulty(context);

    // 1. 立即显示完成页面，使用当前成绩作为最佳成绩的默认值
    _bestScores = {
      currentDifficulty: {
        'time': currentTime,
        'mistakes': currentMistakes,
      }
    };

    // 2. 立即更新UI，显示完成页面，消除加载卡顿
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // 3. 在后台执行所有异步操作
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // 保存最佳成绩
        final isNewBest = await widget.saveBestScore(context);
        if (!mounted) return;

        // 保存游戏统计
        await widget.saveGameStatistics(context);
        if (!mounted) return;

        // 清除保存的游戏
        await widget.clearSavedGame(context);
        if (!mounted) return;

        // 加载最新的最佳成绩
        final updatedScores = await widget.loadBestScores(context);
        if (!mounted) return;

        // 更新最佳成绩显示
        if (mounted) {
          setState(() {
            _bestScores = updatedScores;
          });
        }

        // 如果是新纪录，显示对话框
        if (isNewBest && !_hasShownDialog) {
          _hasShownDialog = true;
          if (mounted) {
            await _showNewRecordDialogAsync();
          }
        }
      } catch (e) {
        // 后台操作失败时，保持当前显示的成绩
        // 不需要额外处理，因为我们已经显示了完成页面
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final responsivePadding = ResponsiveLayout.getResponsivePadding(context);
    final responsiveBorderRadius = ResponsiveLayout.getResponsiveBorderRadius(
      context,
    );
    final buttonSize = ResponsiveLayout.getResponsiveButtonSize(context);
    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final currentDifficulty = widget.getCurrentDifficulty(context);
    final savedBestScore = _bestScores[currentDifficulty];
    final bestScoreTime = savedBestScore != null
        ? widget.getBestScoreTime(context, savedBestScore)
        : widget.formatTime(widget.getElapsedTime(context));
    final bestScoreMistakes = savedBestScore != null
        ? widget.getBestScoreMistakes(context, savedBestScore)
        : widget.getMistakes(context);

    // 加载中显示加载指示器
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                LocalizationUtils.of(context)?.loading ?? 'Loading...',
                style: TextStyle(
                  fontSize: AppTextStyles.fontSizeBody,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          LocalizationUtils.of(context)?.puzzleCompleted ?? 'Puzzle Completed',
          style: TextStyle(
            fontSize: AppTextStyles.fontSizeSubtitle,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF059669),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildConfettiEffect(),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsivePadding,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCelebrationIcon(context, responsiveBorderRadius),
                      SizedBox(
                        height: ResponsiveLayout.getResponsiveSpacing(context),
                      ),
                      _buildCongratulationsText(context, textColor),
                      SizedBox(
                        height: ResponsiveLayout.getResponsiveSpacing(context),
                      ),
                      _buildStatsContainer(
                        context,
                        responsiveBorderRadius,
                        bestScoreTime,
                        bestScoreMistakes,
                        textColor,
                      ),
                      const SizedBox(height: 32),
                      _buildActionButtons(
                        context,
                        buttonSize,
                        responsiveBorderRadius,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiEffect() => Positioned.fill(
      child: AnimatedBuilder(
        animation: _confettiAnimation,
        builder: (context, child) => Stack(
            children: List.generate(50, (index) {
              final size = 5.0 + (index % 5);
              final left = (index * 17.3) % 100;
              final top = (_confettiAnimation.value * 100) - (index * 2) % 50;
              final color = [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.pink,
              ][index % 7];
              
              return Positioned(
                left: left * MediaQuery.of(context).size.width / 100,
                top: top * MediaQuery.of(context).size.height / 100,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
      ),
    );

  Widget _buildCelebrationIcon(
    BuildContext context,
    double borderRadius,
  ) => AnimatedBuilder(
    animation: _scaleAnimation,
    builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.successColor,
                context.successColor.withAlpha(180),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.successColor.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.celebration,
            size: ResponsiveLayout.getResponsiveFontSize(48, context),
            color: Colors.white,
          ),
        ),
      ),
  );

  Widget _buildCongratulationsText(BuildContext context, Color textColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.primary.withAlpha(200),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withAlpha(30),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      LocalizationUtils.of(context)?.congratulations ?? 'Congratulations!',
      style: TextStyle(
        fontSize: ResponsiveLayout.getResponsiveFontSize(24, context),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
  );

  Widget _buildStatsContainer(
    BuildContext context,
    double responsiveBorderRadius,
    String bestScoreTime,
    int bestScoreMistakes,
    Color textColor,
  ) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        _buildDifficultyCard(
          context,
          widget.getLocalizedDifficulty(context),
          responsiveBorderRadius,
          textColor,
        ),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 0.5),
        _buildStatRow(
          context,
          LocalizationUtils.of(context)?.time ?? 'Time',
          widget.formatTime(widget.getElapsedTime(context)),
          bestScoreTime,
          Icons.timer,
          context.infoColor,
          responsiveBorderRadius,
          textColor,
        ),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 0.5),
        _buildStatRow(
          context,
          LocalizationUtils.of(context)?.mistakes ?? 'Mistakes',
          widget.getMistakes(context).toString(),
          bestScoreMistakes.toString(),
          widget.getMistakes(context) == 0 ? Icons.check_circle : Icons.warning,
          widget.getMistakes(context) == 0
              ? context.successColor
              : context.errorColor,
          responsiveBorderRadius,
          textColor,
        ),
      ],
    ),
  );

  Widget _buildDifficultyCard(
    BuildContext context,
    String difficulty,
    double borderRadius,
    Color textColor,
  ) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.warningColor,
          context.warningColor.withAlpha(200),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: context.warningColor.withAlpha(30),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            size: ResponsiveLayout.getResponsiveFontSize(18, context),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            difficulty,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(16, context),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String currentValue,
    String bestValue,
    IconData icon,
    Color iconColor,
    double borderRadius,
    Color textColor,
  ) {
    final isBetter = currentValue == bestValue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardColor,
            context.cardColor.withAlpha(240),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveFontSize(14, context),
                color: textColor.withAlpha(150),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  LocalizationUtils.of(context)?.current ?? 'Current',
                  currentValue,
                  icon,
                  iconColor,
                  isBetter ? context.successColor : null,
                  textColor,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: context.dividerColor.withAlpha(100),
                ),
                _buildStatItem(
                  context,
                  LocalizationUtils.of(context)?.bestScore ?? 'Best',
                  bestValue,
                  Icons.emoji_events,
                  Colors.amber,
                  null,
                  textColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color? highlightColor,
    Color textColor,
  ) => Column(
    children: [
      Icon(
        icon,
        size: ResponsiveLayout.getResponsiveFontSize(18, context),
        color: highlightColor ?? iconColor,
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: ResponsiveLayout.getResponsiveFontSize(20, context),
          color: highlightColor ?? textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveLayout.getResponsiveFontSize(12, context),
          color: textColor.withAlpha(153),
        ),
      ),
    ],
  );

  Widget _buildActionButtons(
    BuildContext context,
    Size buttonSize,
    double borderRadius,
  ) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: ResponsiveLayout.getResponsivePadding(context),
    ),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonSize.height,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.refresh,
                size: ResponsiveLayout.getResponsiveFontSize(24, context),
                color: Colors.white,
              ),
              label: Text(
                LocalizationUtils.of(context)?.startNewGame ?? 'Start New Game',
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveFontSize(16, context),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 2,
              ).copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: widget.isGenerating(context)
                  ? null
                  : () => _startNewGame(context),
            ).withGradientBackground(context.buttonPrimaryGradient),
          ),
        ),
        SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
        Expanded(
          child: SizedBox(
            height: buttonSize.height,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.arrow_back,
                size: ResponsiveLayout.getResponsiveFontSize(24, context),
                color: context.primaryColor,
              ),
              label: Text(
                LocalizationUtils.of(context)?.backToMenu ?? 'Back',
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveFontSize(16, context),
                  fontWeight: FontWeight.w600,
                  color: context.primaryColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 2,
              ).copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: widget.isGenerating(context)
                  ? null
                  : () => widget.navigateToHomeScreen(context),
            ).withGradientBackground(
              context.isDarkMode 
                ? AppColors.darkButtonLoadGameGradient
                : AppColors.buttonLoadGameGradient,
            ),
          ),
        ),
      ],
    ),
  );

  void showLoadingDialog(
    BuildContext context,
    Future<void> Function() onGenerate,
    GameViewModel viewModel,
    VoidCallback? onSuccess,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, child) {
            String progressText = '';
            final customProgress = widget.getProgressText(
              viewModel.generationStage,
            );
            if (customProgress != null) {
              progressText = customProgress;
            }

            return _buildLoadingDialogContent(
              context,
              progressText,
              viewModel,
            );
          },
        ),
      ),
    );

    onGenerate()
        .then((_) {
          if (mounted && context.mounted) {
            // 关闭对话框 - 使用传入的context关闭最近的对话框
            Navigator.of(context).pop();
            if (onSuccess != null) {
              onSuccess();
            }
          }
        })
        .catchError((error) {
          if (mounted && context.mounted) {
            // 关闭对话框
            Navigator.of(context).pop();
            showDialog(
              context: this.context,
              builder: (errorDialogContext) => AlertDialog(
                backgroundColor: Theme.of(context).cardColor,
                title: Text(LocalizationUtils.of(context)?.generationFailedTitle ?? 'Generation Failed'),
                content: Text(
                  '${LocalizationUtils.of(context)?.generationFailedMessage ?? 'Failed to generate game. Please try again.'}\n\n${LocalizationUtils.of(context)?.generationFailedError(error.toString()) ?? 'Error: ${error.toString()}'}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(errorDialogContext).pop(),
                    child: Text(LocalizationUtils.of(context)?.okButton ?? 'OK'),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _buildLoadingDialogContent(
    BuildContext context,
    String progressText,
    GameViewModel viewModel,
  ) => AlertDialog(
    backgroundColor: Theme.of(context).cardColor,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppConstants.spacingExtraLarge),
        Text(
          LocalizationUtils.of(context)?.generatingGame ?? 'Generating game...',
          style: const TextStyle(fontSize: AppTextStyles.fontSizeBody),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        if (progressText.isNotEmpty)
          Text(progressText, style: const TextStyle(fontSize: AppTextStyles.fontSizeLabel)),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          viewModel.cancelGameGeneration();
          Navigator.of(context).pop();
        },
        child: Text(LocalizationUtils.of(context)?.cancel ?? 'Cancel'),
      ),
    ],
  );

  Future<void> _startNewGame(BuildContext context) async {
    if (!mounted) return;

    final viewModel = widget.getViewModel(context);
    showLoadingDialog(
      context,
      () => widget.startNewGame(context),
      viewModel,
      () {
        if (mounted) {
          widget.navigateToGameScreen(this.context);
        }
      },
    );
  }

  Future<void> _showNewRecordDialogAsync() async {
    final difficulty = widget.getLocalizedDifficulty(context);
    final time = widget.formatTime(widget.getElapsedTime(context));
    final mistakes = widget.getMistakes(context);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Text(LocalizationUtils.of(context)?.newRecord ?? 'New Record!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationUtils.of(context)?.newRecordMessage ??
                  'Congratulations! You have set a new record!',
            ),
            const SizedBox(height: 16),
            _buildDialogStatRow(
              LocalizationUtils.of(context)?.difficulty ?? 'Difficulty',
              difficulty,
            ),
            _buildDialogStatRow(
              LocalizationUtils.of(context)?.time ?? 'Time',
              time,
            ),
            _buildDialogStatRow(
              LocalizationUtils.of(context)?.mistakes ?? 'Mistakes',
              mistakes.toString(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationUtils.of(context)?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDialogStatRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    ),
  );
}

extension GradientButton on Widget {
  Widget withGradientBackground(List<Color> colors) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: this,
  );
}
