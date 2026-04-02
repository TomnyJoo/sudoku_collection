import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

/// 通用游戏屏幕模板基类
///
/// 提供游戏屏幕的通用布局框架，支持横向和纵向布局
/// 严格遵循标准数独的布局计算（边距、间距、尺寸比例）
abstract class GameScreenTemplate<TViewModel extends GameViewModel, TSettings extends ChangeNotifier, TFinishScreen extends Widget> extends StatefulWidget {

  const GameScreenTemplate({
    super.key,
    this.autoLoadSavedGame = true,
  });
  final bool autoLoadSavedGame;

  @override
  State<GameScreenTemplate<TViewModel, TSettings, TFinishScreen>> createState() => GameScreenTemplateState<TViewModel, TSettings, TFinishScreen>();

  // ========== 子类必须实现的抽象方法 ==========

  /// 获取游戏标题
  String getTitle(BuildContext context);

  /// 获取设置页面路由
  String getSettingsRoute() => '/settings';

  /// 创建完成页面
  TFinishScreen createFinishScreen();

  /// 计算布局
  GameLayout calculateLayout(Size gameAreaSize);

  /// 构建棋盘
  Widget buildBoard(BuildContext context, TViewModel viewModel, double cellSize);

  // ========== 可选重写的方法（已有默认实现） ==========

  /// 构建数字键盘（默认实现）
  Widget buildNumberKeyboard(BuildContext context, TViewModel viewModel, double buttonSize) => NumberKeyboard(
      onNumberSelected: (int? number) {
        if (number != null) {
          viewModel.setCellValueByNumber(number);
        }
      },
      buttonSize: buttonSize,
      getNumberCount: (context, number) => viewModel.currentGameState.numberCounts[number],
    );

  /// 构建功能键盘（默认实现）
  Widget buildFunctionKeyboard(BuildContext context, TViewModel viewModel, double buttonSize) => FunctionKeyboard(
      onUndo: viewModel.undo,
      onRedo: viewModel.redo,
      onHint: (context) => viewModel.hint(context),
      onMark: viewModel.toggleMarkMode,
      onErase: viewModel.clearCellValue,
      onReset: viewModel.resetGame,
      onAutoMark: viewModel.toggleAutoMarkMode,
      onSolution: viewModel.toggleShowSolution,
      onNew: () {
        final state = context.findAncestorStateOfType<GameScreenTemplateState>();
        state?.confirmNewGame(context, viewModel);
      },
      buttonSize: buttonSize,
      isMarkMode: () => viewModel.currentGameState.isMarkMode,
      isAutoMarkMode: () => viewModel.currentGameState.isAutoMarkMode,
    );

  /// 构建统计栏的额外项目（可选）
  List<Widget>? buildExtraStatItems(BuildContext context, TSettings settings) => null;

  /// 构建标题栏的额外操作按钮（可选）
  List<Widget>? buildTitleActions(BuildContext context, TViewModel viewModel) => null;

  /// 构建自定义标题（可选）
  /// 如果返回null，则使用默认标题构建方式
  Widget? buildCustomTitle(BuildContext context, TViewModel viewModel, {bool isPortrait = true}) => null;

  /// 获取生成阶段的进度文本（默认实现）
  String? getProgressText(dynamic generationStage) =>
      GameUtils.getProgressText(generationStage);

  /// 从标识符获取难度（默认实现）
  Difficulty? getDifficultyFromIdentifier(String identifier) =>
      GameUtils.getDifficultyFromIdentifier(identifier);
}

class GameScreenTemplateState<TViewModel extends GameViewModel, TSettings extends ChangeNotifier, TFinishScreen extends Widget> extends State<GameScreenTemplate<TViewModel, TSettings, TFinishScreen>> with WidgetsBindingObserver {
  late TViewModel _viewModel;
  bool _hasNavigatedToFinish = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appSettings = context.read<AppSettings>();
      final audioManager = AudioManager()
      ..setMusicEnabled(appSettings.musicEnabled);
      if (appSettings.musicEnabled && !audioManager.isMusicPlaying) {
        audioManager.playMusic();
      }
    });
    _viewModel = Provider.of<TViewModel>(context, listen: false);
    _viewModel.addListener(_onGameStateChanged);
    _hasNavigatedToFinish = false;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialNavigation();
    });
  }

  void _handleInitialNavigation() {
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // 如果参数是 GameState，直接使用该状态（从保存游戏列表加载）
    if (args is GameState) {
      _viewModel.loadGameState(args);
      return;
    }
    
    // 如果参数是 Difficulty，开始新游戏
    if (args is Difficulty) {
      _viewModel.startNewGame(args);
      return;
    }
    
    // 如果没有参数，尝试加载保存的游戏
    if (widget.autoLoadSavedGame) {
      _loadSavedGame();
    }
  }

  Future<void> _loadSavedGame() async {
    await _viewModel.loadGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _viewModel.saveGame();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onGameStateChanged);
    // 使用同步方式保存，避免在 dispose 中等待异步操作
    _viewModel.saveGameSync();
    // 先调用pauseGame，再调用super.dispose()，设置notify为false避免触发UI更新
    _viewModel.pauseGame(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<TViewModel>(
      builder: (context, viewModel, child) {
        final navigator = Navigator.of(context);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _viewModel.saveGame().then((_) {
                if (mounted) {
                  navigator.pop();
                }
              });
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final availableHeight = constraints.maxHeight;

              final isHorizontalLayout = availableWidth >= availableHeight;

              final gameAreaWidth = availableWidth;
              final gameAreaHeight = isHorizontalLayout
                  ? availableHeight - kToolbarHeight
                  : availableHeight - kToolbarHeight - 60;

              final layout = widget.calculateLayout(Size(gameAreaWidth, gameAreaHeight));

              final isDarkMode = context.isDarkMode;
              final iconColor = isDarkMode ? Colors.white.withAlpha(200) : AppColors.mutedText;
              
              return Scaffold(
                appBar: !layout.isHorizontalLayout
                    ? AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? null : AppColors.homeLightBackground,
                            gradient: isDarkMode
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: AppColors.darkBackgroundGradient,
                                  )
                                : null,
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back, color: iconColor),
                          onPressed: () async {
                            await _viewModel.saveGame();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        title: _buildTitle(context),
                        foregroundColor: iconColor,
                        actions: [
                          ...?widget.buildTitleActions(context, _viewModel),
                          IconButton(
                            icon: Icon(Icons.help_outline, color: iconColor),
                            onPressed: _showGameRules,
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: iconColor),
                            onPressed: () => _showSettings(context),
                          ),
                        ],
                      )
                    : null,
                body: _buildGameLayout(
                  context,
                  availableWidth,
                  availableHeight,
                  layout,
                ),
              );
            },
          ),
        );
      },
    );

  Widget _buildGameLayout(
    BuildContext context,
    double availableWidth,
    double availableHeight,
    GameLayout layout,
  ) {
    final viewModel = Provider.of<TViewModel>(context);
    if (viewModel.isLoading) {
      return _buildLoadingIndicator(context);
    }

    if (layout.isHorizontalLayout) {
      return Column(
        children: [
          _buildTopToolbar(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildHorizontalGameArea(context, layout, constraints),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildStatsBar(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildVerticalGameArea(context, layout, constraints),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTitle(BuildContext context, {bool isPortrait = true}) {
    // 优先使用自定义标题
    final customTitle = widget.buildCustomTitle(context, _viewModel, isPortrait: isPortrait);
    if (customTitle != null) {
      return customTitle;
    }
    // 默认标题
    return Text(
      widget.getTitle(context),
      style: TextStyle(
        fontSize: isPortrait ? 16 : 18,
        fontWeight: FontWeight.bold,
        color: isPortrait ? null : (context.isDarkMode ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildTopToolbar(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor.withAlpha(180),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () async {
              await _viewModel.saveGame();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 12),
          _buildTitle(context, isPortrait: false),
          const Spacer(),
          _buildStatsRow(context),
          const SizedBox(width: 12),
          ...?widget.buildTitleActions(context, _viewModel),
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: _showGameRules,
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final responsiveBorderRadius = ResponsiveLayout.getResponsiveBorderRadius(context);
    final settings = Provider.of<TSettings>(context);

    final statItems = <Widget>[
      _buildStatItem(
        Icons.timer,
        GameViewModel.formatTime(_viewModel.currentGameState.elapsedTime),
        context.infoColor,
      ),
      _buildStatItem(
        Icons.warning_amber,
        _viewModel.errorCount.toString(),
        context.errorColor,
      ),
      _buildStatItem(
        Icons.star_half,
        _viewModel.getLocalizedDifficulty(context),
        context.warningColor,
      ),
    ];

    final extraItems = widget.buildExtraStatItems(context, settings);
    if (extraItems != null) {
      statItems.addAll(extraItems);
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getResponsivePadding(context) * 0.8,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  context.primaryColor.withAlpha(51),
                  context.primaryColor.withAlpha(26),
                ]
              : [Colors.white.withAlpha(38), Colors.white.withAlpha(13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        border: Border.all(
          color: isDarkMode
              ? context.borderColor.withAlpha(102)
              : Colors.white.withAlpha(51),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: statItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Row(
              children: [
                item,
                if (index < statItems.length - 1)
                  const SizedBox(width: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final responsiveBorderRadius = ResponsiveLayout.getResponsiveBorderRadius(context);
    final settings = Provider.of<TSettings>(context);

    final statItems = <Widget>[
      _buildStatItem(
        Icons.timer,
        GameViewModel.formatTime(_viewModel.currentGameState.elapsedTime),
        context.infoColor,
      ),
      const SizedBox(width: 16),
      _buildStatItem(
        Icons.warning_amber,
        _viewModel.errorCount.toString(),
        context.errorColor,
      ),
      const SizedBox(width: 16),
      _buildStatItem(
        Icons.star_half,
        _viewModel.getLocalizedDifficulty(context),
        context.warningColor,
      ),
    ];

    final extraItems = widget.buildExtraStatItems(context, settings);
    if (extraItems != null) {
      for (int i = 0; i < extraItems.length; i++) {
        statItems..add(const SizedBox(width: 16))
        ..add(extraItems[i]);
      }
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(180),
          borderRadius: BorderRadius.circular(responsiveBorderRadius),
          border: Border.all(color: Colors.grey.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: statItems,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    Color color,
  ) {
    final isDarkMode = context.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveLayout.getResponsiveFontSize(14, context),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _onGameStateChanged() {
    setState(() {});
    if (_viewModel.currentGameState.isCompleted && !_viewModel.showSolution && !_hasNavigatedToFinish) {
      _hasNavigatedToFinish = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<TViewModel>.value(
                value: _viewModel,
                child: widget.createFinishScreen(),
              ),
            ),
          );
        }
      });
    }
  }

  void _showSettings(BuildContext context) {
    Navigator.pushNamed(context, widget.getSettingsRoute());
  }

  void _showGameRules() {
    final localizations = LocalizationUtils.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCard : Colors.white,
        title: Text(
          localizations?.gameRules ?? '游戏规则',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRuleSection(
                context,
                localizations?.gameTypeStandardName ?? '标准数独',
                localizations?.gameTypeStandardDescription ??
                    '填满网格，使得每一行、每一列和每一个3x3的方块都包含1-9且不重复。',
              ),
              const SizedBox(height: 12),
              _buildRuleSection(
                context,
                localizations?.gameTypeJigsawName ?? '锯齿数独',
                localizations?.gameTypeJigsawDescription ??
                    '填满网格，使得每一行、每一列和每一个不规则区域都包含1-9且不重复。',
              ),
              const SizedBox(height: 12),
              _buildRuleSection(
                context,
                localizations?.gameTypeDiagonalName ?? '对角线数独',
                localizations?.gameTypeDiagonalDescription ??
                    '填满网格，使得每一行、每一列、每一个3x3的方块和两条主对角线都包含1-9且不重复。',
              ),
              const SizedBox(height: 12),
              _buildRuleSection(
                context,
                localizations?.gameTypeKillerName ?? '杀手数独',
                localizations?.gameTypeKillerDescription ??
                    '填满网格，使得每一行、每一列和每一个3x3的方块都包含1-9且不重复。每个笼子内的数字之和必须等于笼子显示的值。',
              ),
              const SizedBox(height: 12),
              _buildRuleSection(
                context,
                localizations?.gameTypeWindowName ?? '窗口数独',
                localizations?.gameTypeWindowDescription ??
                    '填满网格，使得每一行、每一列、每一个3x3的方块和四个窗口区域都包含1-9且不重复。',
              ),
              const SizedBox(height: 12),
              _buildRuleSection(
                context,
                localizations?.gameTypeSamuraiName ?? '武士数独',
                localizations?.gameTypeSamuraiDescription ??
                    '武士数独由5个标准数独交叉组成，呈十字形排列。每个标准数独都必须满足：每行、每列、每个3×3宫格都包含1-9的数字，且不重复。',
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations?.ok ?? '确定'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSection(
    BuildContext context,
    String title,
    String description,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : AppColors.darkText;
    final descriptionColor = isDarkMode
        ? Colors.white.withAlpha(200)
        : AppColors.mutedText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(fontSize: 13, color: descriptionColor, height: 1.4),
        ),
      ],
    );
  }

  void confirmNewGame(BuildContext context, TViewModel gameVM) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.cardColor,
        title: Text(
          LocalizationUtils.of(dialogContext)?.newGameConfirm ?? 'New Game Confirm',
        ),
        content: Text(
          LocalizationUtils.of(dialogContext)?.newGameConfirmContent ??
              'Are you sure you want to start a new game? Current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LocalizationUtils.of(dialogContext)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final difficulty = widget.getDifficultyFromIdentifier(gameVM.currentGameState.difficulty);
              if (difficulty != null) {
                showLoadingDialog(context, () => gameVM.startNewGame(difficulty), gameVM);
              }
            },
            child: Text(LocalizationUtils.of(dialogContext)?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void showLoadingDialog(
    BuildContext context,
    Future<void> Function() onGenerate,
    TViewModel viewModel, [
    VoidCallback? onSuccess,
  ]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, child) {
            String progressText = '';
            final customProgress = widget.getProgressText(viewModel.generationStage);
            if (customProgress != null) {
              progressText = customProgress;
            }
            
            return AlertDialog(
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
                    Text(
                      progressText,
                      style: const TextStyle(fontSize: AppTextStyles.fontSizeLabel),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    viewModel.cancelGameGeneration();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(LocalizationUtils.of(context)?.cancel ?? 'Cancel'),
                ),
              ],
            );
          },
        ),
      ),
    );

    onGenerate().then((_) {
      if (mounted) {
        Navigator.of(this.context).pop();
        if (onSuccess != null) {
          onSuccess();
        }
      }
    }).catchError((error) {
      if (mounted) {
        Navigator.of(this.context).pop();
        showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (errorDialogContext) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(LocalizationUtils.of(context)?.generationFailedTitle ?? 'Generation Failed'),
            content: Text(
              '${LocalizationUtils.of(context)?.generationFailedMessage ?? 'Failed to generate game. Please try again.'}\n\n${LocalizationUtils.of(context)?.generationFailedError(error.toString()) ?? 'Error: ${error.toString()}'}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(errorDialogContext).pop();
                  Navigator.of(this.context).pop();
                },
                child: Text(LocalizationUtils.of(context)?.okButton ?? 'OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildHorizontalGameArea(
    BuildContext context,
    GameLayout layout,
    BoxConstraints constraints,
  ) {
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;
    final viewModel = Provider.of<TViewModel>(context);

    return Stack(
      children: [
        Positioned(
          left: (availableWidth - layout.boardSize - LayoutCalculator.spacing - layout.keypadWidth) / 2,
          top: (availableHeight - layout.boardSize) / 2,
          child: SizedBox(
            width: layout.boardSize,
            height: layout.boardSize,
            child: widget.buildBoard(context, viewModel, layout.boardCellSize),
          ),
        ),
        Positioned(
          left: (availableWidth - layout.boardSize - LayoutCalculator.spacing - layout.keypadWidth) / 2 + layout.boardSize + LayoutCalculator.spacing,
          top: (availableHeight - layout.keypadHeight) / 2,
          child: SizedBox(
            width: layout.keypadWidth,
            height: layout.keypadHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: layout.keypadHeight / 2,
                  child: widget.buildNumberKeyboard(context, viewModel, layout.keypadCellSize),
                ),
                SizedBox(
                  height: layout.keypadHeight / 2,
                  child: widget.buildFunctionKeyboard(context, viewModel, layout.keypadCellSize),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalGameArea(
    BuildContext context,
    GameLayout layout,
    BoxConstraints constraints,
  ) {
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;
    final viewModel = Provider.of<TViewModel>(context);

    return Stack(
      children: [
        Positioned(
          left: (availableWidth - layout.boardSize) / 2,
          top: (availableHeight - layout.boardSize - LayoutCalculator.spacing - layout.keypadHeight) / 2,
          child: SizedBox(
            width: layout.boardSize,
            height: layout.boardSize,
            child: widget.buildBoard(context, viewModel, layout.boardCellSize),
          ),
        ),
        Positioned(
          left: (availableWidth - layout.keypadWidth) / 2,
          top: (availableHeight - layout.boardSize - LayoutCalculator.spacing - layout.keypadHeight - LayoutCalculator.keypadBottomMargin) / 2 + layout.boardSize + LayoutCalculator.spacing,
          child: SizedBox(
            width: layout.keypadWidth,
            height: layout.keypadHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: layout.keypadWidth / 2,
                  child: widget.buildNumberKeyboard(context, viewModel, layout.keypadCellSize),
                ),
                SizedBox(
                  width: layout.keypadWidth / 2,
                  child: widget.buildFunctionKeyboard(context, viewModel, layout.keypadCellSize),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) => AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        String progressText = '';
        final customProgress = widget.getProgressText(_viewModel.generationStage);
        if (customProgress != null) {
          progressText = customProgress;
        }
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                LocalizationUtils.of(context)?.generatingGame ?? 'Generating game...',
                style: TextStyle(
                  fontSize: AppTextStyles.fontSizeBody,
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (progressText.isNotEmpty)
                Text(
                  progressText,
                  style: TextStyle(
                    fontSize: AppTextStyles.fontSizeLabel,
                    fontWeight: FontWeight.w500,
                    color: context.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  _viewModel.cancelGameGeneration();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                label: Text(
                  LocalizationUtils.of(context)?.cancel ?? 'Cancel',
                  style: const TextStyle(
                    fontSize: AppTextStyles.fontSizeBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
}
