import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

/// 通用设置页面, 可以通过继承此类来扩展设置页面，添加自定义标签页
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

/// SettingsScreen的状态类, 可以被继承以自定义设置页面的行为
class SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  /// Tab控制器，子类可以访问
  late TabController tabController;

  /// 音频管理器
  late final AudioManager _audioManager;

  /// 额外的标签页数量，子类可以通过重写此getter来添加自定义标签页
  int get additionalTabCount => 0;

  /// 获取总标签页数量
  int get totalTabCount => 2 + additionalTabCount;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: totalTabCount, vsync: this);
    _audioManager = AudioManager();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettings>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BasePageLayout(
      title: l10n?.settingsTitle ?? 'Settings',
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              indicatorColor: AppColors.buttonPrimary,
              labelColor: AppColors.buttonPrimary,
              unselectedLabelColor: isDarkMode
                  ? Colors.white.withAlpha(179)
                  : AppColors.mutedText,
              tabs: buildTabs(context, l10n),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: buildTabViews(context, appSettings, isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标签页列表，子类可以重写此方法添加自定义标签
  List<Widget> buildTabs(BuildContext context, AppLocalizations? l10n) => [
    Tab(text: l10n?.settingsBasicSettings ?? 'Basic Settings'),
    Tab(text: l10n?.settingsGameSettingsTab ?? 'Game Settings'),
  ];

  /// 构建标签页内容列表，子类可以重写此方法添加自定义内容
  List<Widget> buildTabViews(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) => [
    buildBasicSettingsTab(context, appSettings, isDarkMode),
    buildGameSettingsTab(context, appSettings, isDarkMode),
  ];

  /// 构建基本设置标签页
  Widget buildBasicSettingsTab(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLanguageSection(context, appSettings, isDarkMode),
            const SizedBox(height: 24),
            buildThemeSection(context, appSettings, isDarkMode),
            const SizedBox(height: 24),
            buildAudioSection(context, appSettings, isDarkMode),
          ],
        ),
      ),
    );

  /// 构建游戏设置标签页
  Widget buildGameSettingsTab(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildGameSettingsSection(context, appSettings, isDarkMode),
            const SizedBox(height: 24),
            buildAdvancedSettingsSection(context, appSettings, isDarkMode),
          ],
        ),
      ),
    );

  /// 构建语言设置区域
  Widget buildLanguageSection(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) {
    final localization = LocalizationUtils.of(context);
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;
    final titleColor = isDarkMode ? Colors.white : AppColors.darkText;
    const selectedColor = AppColors.buttonPrimary;
    final unselectedColor = isDarkMode
        ? AppColors.darkUnselectedBackground
        : AppColors.lightBackground;
    const selectedTextColor = Colors.white;
    final unselectedTextColor = isDarkMode
        ? Colors.white.withAlpha(179)
        : AppColors.mutedText;

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization?.settingsLanguage ?? 'Language',
              style: TextStyle(
                fontSize: AppTextStyles.fontSizeButton,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                  width: constraints.maxWidth,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'en',
                        label: Text('English'),
                      ),
                      ButtonSegment<String>(value: 'zh', label: Text('中文')),
                    ],
                    selected: {appSettings.language},
                    onSelectionChanged: (Set<String> newSelection) {
                      if (newSelection.isNotEmpty) {
                        appSettings.setLanguage(newSelection.first);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return selectedColor;
                        }
                        return unselectedColor;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return selectedTextColor;
                        }
                        return unselectedTextColor;
                      }),
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主题设置区域
  Widget buildThemeSection(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) {
    final localization = LocalizationUtils.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;
    final titleColor = isDarkMode ? Colors.white : AppColors.darkText;
    const selectedColor = AppColors.buttonPrimary;
    final unselectedColor = isDarkMode
        ? AppColors.darkUnselectedBackground
        : AppColors.lightBackground;
    const selectedTextColor = Colors.white;
    final unselectedTextColor = isDarkMode
        ? Colors.white.withAlpha(179)
        : AppColors.mutedText;

    // 将ThemeMode转换为bool值（false=Light, true=Dark）
    // 如果是system模式，根据当前亮度决定
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = themeManager.themeMode == ThemeMode.dark ||
        (themeManager.themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization?.settingsTheme ?? 'Theme',
              style: TextStyle(
                fontSize: AppTextStyles.fontSizeButton,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                  width: constraints.maxWidth,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text(
                          localization?.settingsThemeLight ?? 'Light',
                        ),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text(localization?.settingsThemeDark ?? 'Dark'),
                      ),
                    ],
                    selected: {isDark},
                    onSelectionChanged: (Set<bool> newSelection) {
                      if (newSelection.isNotEmpty) {
                        // 将bool值转换为ThemeMode
                        final newMode = newSelection.first ? ThemeMode.dark : ThemeMode.light;
                        themeManager.setThemeMode(newMode);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return selectedColor;
                        }
                        return unselectedColor;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return selectedTextColor;
                        }
                        return unselectedTextColor;
                      }),
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建音频设置区域
  Widget buildAudioSection(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) {
    final localization = LocalizationUtils.of(context);
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;
    final titleColor = isDarkMode ? Colors.white : AppColors.darkText;
    final textColor = isDarkMode ? Colors.white : AppColors.darkText;
    const activeColor = AppColors.buttonPrimary;
    final inactiveTrackColor = isDarkMode
        ? AppColors.darkUnselectedBackground
        : AppColors.lightBackground;

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization?.settingsAudio ?? 'Audio',
              style: TextStyle(
                fontSize: AppTextStyles.fontSizeButton,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                localization?.settingsMusic ?? 'Music',
                style: TextStyle(color: textColor),
              ),
              value: appSettings.musicEnabled,
              onChanged: (value) async {
                await appSettings.toggleMusic(value);
                _audioManager.setMusicEnabled(value);
                if (value) {
                  await _audioManager.playMusic();
                } else {
                  await _audioManager.pauseMusic();
                }
              },
              activeThumbColor: activeColor,
              inactiveTrackColor: inactiveTrackColor,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(
                localization?.soundEffects ?? 'Sound Effects',
                style: TextStyle(color: textColor),
              ),
              value: appSettings.soundEffectsEnabled,
              onChanged: (value) async {
                await appSettings.toggleSoundEffects(value);
                _audioManager.soundEffectEnabled = value;
              },
              activeThumbColor: activeColor,
              inactiveTrackColor: inactiveTrackColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建游戏设置区域
  Widget buildGameSettingsSection(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) {
    final l10n = AppLocalizations.of(context);
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;
    final titleColor = isDarkMode ? Colors.white : AppColors.darkText;
    final textColor = isDarkMode ? Colors.white : AppColors.darkText;
    const activeColor = AppColors.buttonPrimary;
    final inactiveTrackColor = isDarkMode
        ? AppColors.darkUnselectedBackground
        : AppColors.lightBackground;

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.settingsGameSettings ?? 'Game Settings',
              style: TextStyle(
                fontSize: AppTextStyles.fontSizeButton,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                l10n?.settingsAutoCheck ?? 'Auto Check',
                style: TextStyle(color: textColor),
              ),
              value: appSettings.autoCheckEnabled,
              onChanged: appSettings.toggleAutoCheck,
              activeThumbColor: activeColor,
              inactiveTrackColor: inactiveTrackColor,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(
                l10n?.settingsHighlightMistakes ?? 'Highlight Mistakes',
                style: TextStyle(color: textColor),
              ),
              value: appSettings.highlightMistakesEnabled,
              onChanged: appSettings.toggleHighlightMistakes,
              activeThumbColor: activeColor,
              inactiveTrackColor: inactiveTrackColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建高级设置区域
  Widget buildAdvancedSettingsSection(
    BuildContext context,
    AppSettings appSettings,
    bool isDarkMode,
  ) {
    final l10n = AppLocalizations.of(context);
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;
    final titleColor = isDarkMode ? Colors.white : AppColors.darkText;
    final textColor = isDarkMode ? Colors.white : AppColors.darkText;
    const activeColor = AppColors.buttonPrimary;
    final inactiveTrackColor = isDarkMode
        ? AppColors.darkUnselectedBackground
        : AppColors.lightBackground;

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.settingsCandidateSettings ?? '候选数设置',
              style: TextStyle(
                fontSize: AppTextStyles.fontSizeButton,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                l10n?.settingsUseAdvancedStrategy ?? 'Use Advanced Strategy',
                style: TextStyle(color: textColor),
              ),
              value: appSettings.useAdvancedStrategy,
              onChanged: appSettings.toggleShowAdvancedOptions,
              activeThumbColor: activeColor,
              inactiveTrackColor: inactiveTrackColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置屏幕包装器
class SettingsScreenWrapper extends StatelessWidget {
  const SettingsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: context.read<AppSettings>(),
    child: const SettingsScreen(),
  );
}
