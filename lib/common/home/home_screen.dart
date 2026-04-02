import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/index.dart';
import 'package:sudoku/games/jigsaw/index.dart';
import 'package:sudoku/games/killer/index.dart';
import 'package:sudoku/games/samurai/index.dart';
import 'package:sudoku/games/standard/index.dart';
import 'package:sudoku/games/window/index.dart';

/// 首页
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 首页状态管理
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GameType? _selectedGameType;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String _version = '';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appSettings = context.read<AppSettings>();
      await appSettings.loadSettings();
      final audioManager = AudioManager()
      ..setMusicEnabled(appSettings.musicEnabled);
      if (appSettings.musicEnabled) {
        await audioManager.playMusic();
      }
      
      // 获取版本信息
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? null : context.homeBackground,
          gradient: isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.darkBackgroundGradient,
                )
              : null,
        ),
        child: Column(
          children: [
            _buildAppBar(context, isDarkMode),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: _buildMainLayout,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    final iconBgColor = isDarkMode
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(8);
    final iconColor = isDarkMode
        ? Colors.white.withAlpha(200)
        : AppColors.mutedText;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? null : context.homeBackground,
          gradient: isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.darkBackgroundGradient,
                )
              : null,
        ),
      ),
      actions: [
        _buildIconButton(
          context,
          icon: Icons.help_outline,
          bgColor: iconBgColor,
          iconColor: iconColor,
          onTap: () => _showHelpDialog(context),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          context,
          icon: Icons.settings,
          bgColor: iconBgColor,
          iconColor: iconColor,
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          context,
          icon: Icons.bar_chart,
          bgColor: iconBgColor,
          iconColor: iconColor,
          onTap: () => Navigator.pushNamed(context, '/statistics'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
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

  Widget _buildMainLayout(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = LocalizationUtils.of(context);

    final horizontalPadding = width < 400 ? 16.0 : 24.0;
    const titleHeight = 40.0;
    const footerHeight = 32.0;
    const spacing = 16.0;

    // 计算可用高度：总高度 - 标题 - 版权 - 间距
    final availableHeight =
        height - titleHeight - footerHeight - spacing * 2;

    // 防御性检查：确保可用高度不为负值
    final safeAvailableHeight = availableHeight > 0 ? availableHeight : 0.0;

    // 按比例分配剩余空间给游戏类型和难度选择（各占50%）
    final gameTypeHeight = safeAvailableHeight * 0.5;
    final difficultyHeight = safeAvailableHeight * 0.5;

    return Column(
      children: [
        SizedBox(
          height: titleHeight,
          child: _buildTitle(context, isDarkMode, localizations),
        ),
        const SizedBox(height: spacing),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              SizedBox(
                height: gameTypeHeight,
                child: _buildGameTypeSection(
                  context,
                  isDarkMode,
                  localizations,
                ),
              ),
              const SizedBox(height: spacing),
              SizedBox(
                height: difficultyHeight,
                child: _buildDifficultySection(
                  context,
                  isDarkMode,
                  localizations,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          height: footerHeight,
          child: _buildFooter(context, isDarkMode, localizations),
        ),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations? localizations,
  ) {
    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Center(
      child: Text(
        localizations?.appName ?? '数独',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );

  Widget _buildGameTypeSection(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations? localizations,
  ) {
    final labelColor = isDarkMode ? Colors.white : AppColors.darkText;

    final gameTypes = [
      (
        GameType.standard,
        localizations?.gameTypeStandardName ?? '标准数独',
        Icons.grid_on,
        AppColors.standardSudoku,
      ),
      (
        GameType.jigsaw,
        localizations?.gameTypeJigsawName ?? '锯齿数独',
        Icons.extension,
        AppColors.jigsawSudoku,
      ),
      (
        GameType.diagonal,
        localizations?.gameTypeDiagonalName ?? '对角线数独',
        Icons.control_camera,
        AppColors.diagonalSudoku,
      ),
      (
        GameType.killer,
        localizations?.gameTypeKillerName ?? '杀手数独',
        Icons.calculate,
        AppColors.killerSudoku,
      ),
      (
        GameType.window,
        localizations?.gameTypeWindowName ?? '窗口数独',
        Icons.window,
        AppColors.windowSudoku,
      ),
      (
        GameType.samurai,
        localizations?.gameTypeSamuraiName ?? '武士数独',
        Icons.supervisor_account,
        AppColors.samuraiSudoku,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.selectSudokuType ?? '选择数独类型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemHeight = (constraints.maxHeight - 16) / 3;
              final itemWidth = (constraints.maxWidth - 16) / 3;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gameTypes.map((item) {
                  final (type, title, icon, color) = item;
                  final isSelected = _selectedGameType == type;
                  return _buildGameTypeChip(
                    context,
                    type,
                    title,
                    icon,
                    color,
                    isSelected,
                    isDarkMode,
                    itemWidth,
                    itemHeight,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameTypeChip(
    BuildContext context,
    GameType type,
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    bool isDarkMode,
    double width,
    double height,
  ) {
    final textColor = isSelected
        ? Colors.white
        : (isDarkMode ? Colors.white.withAlpha(200) : AppColors.mutedText);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameType = isSelected ? null : type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withAlpha(220)],
                )
              : null,
          color: isSelected
              ? null
              : (isDarkMode ? Colors.white.withAlpha(15) : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDarkMode ? Colors.white.withAlpha(25) : Colors.black.withAlpha(10)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withAlpha(60)
                  : (isDarkMode ? Colors.black.withAlpha(20) : Colors.black.withAlpha(8)),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations? localizations,
  ) {
    final labelColor = isDarkMode ? Colors.white : AppColors.darkText;
    final placeholderColor = isDarkMode
        ? Colors.white.withAlpha(100)
        : AppColors.mutedText.withAlpha(150);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.selectDifficulty ?? '选择难度',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withAlpha(8) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withAlpha(12)
                    : Colors.black.withAlpha(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withAlpha(20)
                      : Colors.black.withAlpha(6),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _selectedGameType == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 32,
                          color: placeholderColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations?.selectSudokuTypeHint ?? '请先选择数独类型',
                          style: TextStyle(
                            fontSize: 13,
                            color: placeholderColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildDifficultyContent(context, isDarkMode, localizations),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyContent(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations? localizations,
  ) {
    final gameConfig = _getGameConfig(_selectedGameType!);
    final gameColor = gameConfig['color'] as Color;
    final difficulties = [
      (Difficulty.beginner, localizations?.difficultyBeginner ?? '入门'),
      (Difficulty.easy, localizations?.difficultyEasy ?? '简单'),
      (Difficulty.medium, localizations?.difficultyMedium ?? '中等'),
      (Difficulty.hard, localizations?.difficultyHard ?? '困难'),
      (Difficulty.expert, localizations?.difficultyExpert ?? '专家'),
      (Difficulty.master, localizations?.difficultyMaster ?? '大师'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final showCustomGame = gameConfig['showCustomGame'] as bool;
        const spacing = 8.0;
        const runSpacing = 8.0;
        
        // 计算是否有保存的游戏
        final hasSavedGame = _checkCurrentGameTypeHasSavedGame();
        
        // 计算底部操作按钮区域
        final hasActionButtons = showCustomGame || hasSavedGame;
        final actionButtonHeight = hasActionButtons ? 40.0 : 0.0;
        
        // 难度按钮区域高度（每行3个，共2行）
        final buttonAreaHeight = constraints.maxHeight - actionButtonHeight - (hasActionButtons ? spacing : 0);
        final itemHeight = (buttonAreaHeight - runSpacing) / 2;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;

        return Column(
          children: [
            SizedBox(
              height: buttonAreaHeight,
              child: Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                children: difficulties.map((item) {
                  final (difficulty, label) = item;
                  return _buildDifficultyButton(
                    context,
                    difficulty,
                    label,
                    gameColor,
                    itemWidth,
                    itemHeight,
                  );
                }).toList(),
              ),
            ),
            if (hasActionButtons) ...[
              const SizedBox(height: spacing),
              SizedBox(
                height: actionButtonHeight,
                child: _buildActionButtonsRow(
                  context,
                  showCustomGame,
                  hasSavedGame,
                  gameColor,
                  isDarkMode,
                  localizations,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  /// 检查当前选中的游戏类型是否有保存的游戏
  // ignore: prefer_expression_function_bodies
  bool _checkCurrentGameTypeHasSavedGame() {
    // 这个值会在 FutureBuilder 中更新，这里先返回 true 占位
    // 实际逻辑在 _buildActionButtonsRow 中处理
    return true;
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    Difficulty difficulty,
    String label,
    Color gameColor,
    double width,
    double height,
  ) => GestureDetector(
      onTap: () => _startGame(context, difficulty),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gameColor, gameColor.withAlpha(200)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withAlpha(60),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gameColor.withAlpha(40),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

  Widget _buildActionButtonsRow(
    BuildContext context,
    bool showCustomGame,
    bool hasSavedGame,
    Color gameColor,
    bool isDarkMode,
    AppLocalizations? localizations,
  ) => FutureBuilder<bool>(
      future: _checkHasSavedGameForCurrentType(),
      builder: (context, snapshot) {
        final actuallyHasSavedGame = snapshot.data ?? false;
        final buttons = <Widget>[];

        // 继续游戏按钮（如果有保存的游戏）
        if (actuallyHasSavedGame) {
          buttons.add(
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.play_circle_outline,
                label: localizations?.loadGame ?? '加载游戏',
                color: gameColor,
                onTap: () => _continueSavedGame(context),
                isDarkMode: isDarkMode,
              ),
            ),
          );
        }

        // 自定义按钮
        if (showCustomGame) {
          buttons.add(
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.edit_outlined,
                label: localizations?.customGame ?? '自定义',
                color: gameColor,
                onTap: () => _openCustomGame(context),
                isDarkMode: isDarkMode,
              ),
            ),
          );
        }

        return Row(children: buttons);
      },
    );
  
  /// 检查当前选中的游戏类型是否有保存的游戏
  Future<bool> _checkHasSavedGameForCurrentType() async {
    if (_selectedGameType == null) return false;
    
    final gameType = _selectedGameType!.name;
    final savedGames = await GameSaveManager.getAllSavedGames();
    return savedGames.any((game) => game.gameType == gameType);
  }
  
  /// 继续当前游戏类型的保存游戏
  Future<void> _continueSavedGame(BuildContext context) async {
    if (_selectedGameType == null) return;
    
    final gameType = _selectedGameType!.name;
    final savedGames = await GameSaveManager.getAllSavedGames();
    final savedGame = savedGames.firstWhere(
      (game) => game.gameType == gameType,
      orElse: () => throw Exception('No saved game found'),
    );
    
    await _loadSavedGame(savedGame);
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final bgColor = color.withAlpha(30);
    final borderColor = color.withAlpha(60);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations? localizations,
  ) {
    final textColor = isDarkMode
        ? Colors.white.withAlpha(80)
        : AppColors.mutedText.withAlpha(160);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizations?.homeVersion(_version) ?? 'v$_version',
            style: TextStyle(fontSize: 10, color: textColor),
          ),
          const SizedBox(width: 12),
          Text(
            localizations?.homeCopyright ?? '© 2026 Topking Software',
            style: TextStyle(fontSize: 10, color: textColor),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getGameConfig(GameType type) {
    switch (type) {
      case GameType.standard:
        return {'color': AppColors.standardSudoku, 'showCustomGame': true};
      case GameType.jigsaw:
        return {'color': AppColors.jigsawSudoku, 'showCustomGame': false};
      case GameType.diagonal:
        return {'color': AppColors.diagonalSudoku, 'showCustomGame': true};
      case GameType.killer:
        return {'color': AppColors.killerSudoku, 'showCustomGame': false};
      case GameType.window:
        return {'color': AppColors.windowSudoku, 'showCustomGame': false};
      case GameType.samurai:
        return {'color': AppColors.samuraiSudoku, 'showCustomGame': false};
      case GameType.custom:
        return {'color': AppColors.primary, 'showCustomGame': false};
    }
  }

  void _startGame(BuildContext context, Difficulty difficulty) {
    if (_selectedGameType == null) return;

    switch (_selectedGameType!) {
      case GameType.standard:
        Navigator.pushNamed(context, '/standard_game', arguments: difficulty);
        break;
      case GameType.jigsaw:
        Navigator.pushNamed(context, '/jigsaw_game', arguments: difficulty);
        break;
      case GameType.diagonal:
        Navigator.pushNamed(context, '/diagonal_game', arguments: difficulty);
        break;
      case GameType.killer:
        Navigator.pushNamed(context, '/killer_game', arguments: difficulty);
        break;
      case GameType.window:
        Navigator.pushNamed(context, '/window_game', arguments: difficulty);
        break;
      case GameType.samurai:
        Navigator.pushNamed(context, '/samurai_game', arguments: difficulty);
        break;
      case GameType.custom:
        break;
    }
  }

  void _openCustomGame(BuildContext context) {
    if (_selectedGameType == null) return;

    switch (_selectedGameType!) {
      case GameType.standard:
        Navigator.pushNamed(context, '/standard_custom');
        break;
      case GameType.jigsaw:
        break;
      case GameType.diagonal:
        Navigator.pushNamed(context, '/diagonal_custom');
        break;
      case GameType.killer:
        break;
      case GameType.window:
        break;
      case GameType.samurai:
        break;
      case GameType.custom:
        break;
    }
  }

  Future<void> _loadSavedGame(SavedGameInfo gameInfo) async {
    switch (gameInfo.gameType) {
      case 'standard':
        final service = StandardGameService();
        final savedState = await service.loadGameState(gameInfo.saveKey);
        if (savedState != null && mounted) {
          await Navigator.pushNamed(context, '/standard_game', arguments: savedState);
        }
        break;
      case 'jigsaw':
        final service = JigsawGameService();
        final savedState = await service.loadGameState(gameInfo.saveKey);
        if (savedState != null && mounted) {
          await Navigator.pushNamed(context, '/jigsaw_game', arguments: savedState);
        }
        break;
      case 'diagonal':
        final service = DiagonalGameService();
        final savedState = await service.loadGameState(gameInfo.saveKey);
        if (savedState != null && mounted) {
          await Navigator.pushNamed(context, '/diagonal_game', arguments: savedState);
        }
        break;
      case 'killer':
        final service = KillerGameService();
        final savedState = await service.loadGameState(gameInfo.saveKey);
        if (savedState != null && mounted) {
          await Navigator.pushNamed(context, '/killer_game', arguments: savedState);
        }
        break;
      case 'window':
        final service = WindowGameService();
        final savedState = await service.loadGameState(gameInfo.saveKey);
        if (savedState != null && mounted) {
          await Navigator.pushNamed(context, '/window_game', arguments: savedState);
        }
        break;
      case 'samurai':
        final service = SamuraiGameService();
        final savedState = await service.loadGameState(gameInfo.saveKey);
        if (savedState != null && mounted) {
          await Navigator.pushNamed(context, '/samurai_game', arguments: savedState);
        }
        break;
    }
  }
}
