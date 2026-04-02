import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Active game types label
  ///
  /// In en, this message translates to:
  /// **'Active Game Types'**
  String get activeGameTypes;

  /// Advanced exclusion logic setting
  ///
  /// In en, this message translates to:
  /// **'Advanced Exclusion Logic'**
  String get advancedExclusion;

  /// Advanced settings tab
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appName;

  /// Auto check setting
  ///
  /// In en, this message translates to:
  /// **'Auto Check'**
  String get autoCheck;

  /// Auto Mark button
  ///
  /// In en, this message translates to:
  /// **'Auto Mark'**
  String get autoMark;

  /// Auto mark possibilities description
  ///
  /// In en, this message translates to:
  /// **'Auto Mark Possibilities'**
  String get autoMarkPossibilities;

  /// Auto save setting
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// Average mistakes label
  ///
  /// In en, this message translates to:
  /// **'Average Mistakes'**
  String get averageMistakes;

  /// Average time label
  ///
  /// In en, this message translates to:
  /// **'Average Time'**
  String get averageTime;

  /// Back to menu button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backToMenu;

  /// Basic settings tab
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get basicSettings;

  /// Best score label
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// Best score rule description
  ///
  /// In en, this message translates to:
  /// **'Record rule: shorter time, or same time with fewer mistakes'**
  String get bestScoreRule;

  /// Best time label
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// Better performance indicator
  ///
  /// In en, this message translates to:
  /// **'Better'**
  String get better;

  /// Block exclusion logic
  ///
  /// In en, this message translates to:
  /// **'Block Exclusion'**
  String get blockExclusion;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Clear best scores button
  ///
  /// In en, this message translates to:
  /// **'Clear Best Scores'**
  String get clearBestScores;

  /// Clear board button
  ///
  /// In en, this message translates to:
  /// **'Clear Board'**
  String get clearBoard;

  /// Clear board confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the board?'**
  String get clearBoardConfirm;

  /// Clear cell description
  ///
  /// In en, this message translates to:
  /// **'Clear Cell'**
  String get clearCell;

  /// Clear statistics button
  ///
  /// In en, this message translates to:
  /// **'Clear Statistics'**
  String get clearStatistics;

  /// Clear statistics confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all statistics? This action cannot be undone.'**
  String get clearStatisticsConfirmMessage;

  /// Clear statistics confirmation title
  ///
  /// In en, this message translates to:
  /// **'Confirm Clear Statistics'**
  String get clearStatisticsConfirmTitle;

  /// Combined statistics title
  ///
  /// In en, this message translates to:
  /// **'Combined Statistics'**
  String get combinedStatistics;

  /// Completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Completed games label
  ///
  /// In en, this message translates to:
  /// **'Completed Games'**
  String get completedGames;

  /// Completion rate label
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Current label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Custom difficulty title
  ///
  /// In en, this message translates to:
  /// **'Custom Difficulty'**
  String get customDifficulty;

  /// Custom game title
  ///
  /// In en, this message translates to:
  /// **'Custom Game'**
  String get customGame;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get customGameError;

  /// Error message when board is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid board: some numbers conflict with each other.'**
  String get customGameErrorInvalid;

  /// Error message when board has multiple solutions
  ///
  /// In en, this message translates to:
  /// **'This board has multiple solutions. Please add more numbers.'**
  String get customGameErrorMultipleSolutions;

  /// Error message when too few cells are filled
  ///
  /// In en, this message translates to:
  /// **'Please fill at least 17 cells.'**
  String get customGameErrorTooFew;

  /// Custom game instruction 1
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to select it'**
  String get customGameInstruction1;

  /// Custom game instruction 2
  ///
  /// In en, this message translates to:
  /// **'Use the number pad to fill in numbers'**
  String get customGameInstruction2;

  /// Custom game instruction 3
  ///
  /// In en, this message translates to:
  /// **'Tap the same number to delete it'**
  String get customGameInstruction3;

  /// Custom game instruction 4
  ///
  /// In en, this message translates to:
  /// **'Tap \"Start Game\" when finished'**
  String get customGameInstruction4;

  /// Custom game instructions title
  ///
  /// In en, this message translates to:
  /// **'Custom Game Instructions'**
  String get customGameInstructions;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Beginner difficulty level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get difficultyBeginner;

  /// Custom difficulty level
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get difficultyCustom;

  /// Difficulty distribution section title
  ///
  /// In en, this message translates to:
  /// **'Difficulty Distribution'**
  String get difficultyDistribution;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// Expert difficulty level
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyExpert;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// Master difficulty level
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get difficultyMaster;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// Difficulty performance title
  ///
  /// In en, this message translates to:
  /// **'Difficulty Performance'**
  String get difficultyPerformance;

  /// Difficulty statistics section title
  ///
  /// In en, this message translates to:
  /// **'Difficulty Statistics'**
  String get difficultyStatistics;

  /// Efficient label (short)
  ///
  /// In en, this message translates to:
  /// **'Efficient'**
  String get efficient;

  /// Efficient mode description
  ///
  /// In en, this message translates to:
  /// **'Efficient Mode: Uses preset templates for fast generation with stable quality'**
  String get efficientModeDescription;

  /// Equal games played message
  ///
  /// In en, this message translates to:
  /// **'Both games played equally'**
  String get equalGamesPlayed;

  /// Erase button
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get erase;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Export statistics failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to export statistics'**
  String get exportFailed;

  /// Export statistics button
  ///
  /// In en, this message translates to:
  /// **'Export Statistics'**
  String get exportStatistics;

  /// Game comparison title
  ///
  /// In en, this message translates to:
  /// **'Game Comparison'**
  String get gameComparison;

  /// Game completion rate
  ///
  /// In en, this message translates to:
  /// **'Game Completion Rate'**
  String get gameCompletionRate;

  /// Display difficulty level
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {level}'**
  String gameDifficulty(Object level);

  /// Display mistake count
  ///
  /// In en, this message translates to:
  /// **'Mistakes: {count}'**
  String gameMistakes(Object count);

  /// Game rules dialog title
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get gameRules;

  /// Game settings section header
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// Display game time
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String gameTime(Object time);

  /// Game trends title
  ///
  /// In en, this message translates to:
  /// **'Game Trends'**
  String get gameTrends;

  /// Custom Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'A fully customizable Sudoku game where you can set any rules and regions'**
  String get gameTypeCustomDescription;

  /// Custom Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Custom Sudoku'**
  String get gameTypeCustomName;

  /// Diagonal Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'In addition to standard rules, numbers on both main diagonals cannot repeat'**
  String get gameTypeDiagonalDescription;

  /// Diagonal Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Diagonal Sudoku'**
  String get gameTypeDiagonalName;

  /// Jigsaw Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'A Sudoku game with irregular regions where numbers cannot repeat within each region'**
  String get gameTypeJigsawDescription;

  /// Jigsaw Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Jigsaw Sudoku'**
  String get gameTypeJigsawName;

  /// Killer Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'Contains numbers and regions, where the sum of numbers in each region must equal the specified value'**
  String get gameTypeKillerDescription;

  /// Killer Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Killer Sudoku'**
  String get gameTypeKillerName;

  /// Samurai Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'A complex Sudoku game composed of five standard Sudoku puzzles intersecting'**
  String get gameTypeSamuraiDescription;

  /// Samurai Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Samurai Sudoku'**
  String get gameTypeSamuraiName;

  /// Standard Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'Classic 9x9 Sudoku game where each row, column, and 3x3 block must contain digits 1-9 without repetition'**
  String get gameTypeStandardDescription;

  /// Standard Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Standard Sudoku'**
  String get gameTypeStandardName;

  /// Window Sudoku game type description
  ///
  /// In en, this message translates to:
  /// **'A Sudoku game with four 3x3 window regions where numbers cannot repeat within window regions'**
  String get gameTypeWindowDescription;

  /// Window Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Window Sudoku'**
  String get gameTypeWindowName;

  /// Generating game message
  ///
  /// In en, this message translates to:
  /// **'Generating game, please wait...'**
  String get generatingGame;

  /// Generation failed error
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String generationFailedError(Object error);

  /// Generation failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to generate game. Please try again.'**
  String get generationFailedMessage;

  /// Generation failed title
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get generationFailedTitle;

  /// Generator label (short)
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generator;

  /// Get hint description
  ///
  /// In en, this message translates to:
  /// **'Get Hint'**
  String get getHint;

  /// Help button
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Hint button
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Hidden pairs/triples exclusion logic
  ///
  /// In en, this message translates to:
  /// **'Hidden Pairs/Triples'**
  String get hiddenPairsTriples;

  /// Hidden singles exclusion logic
  ///
  /// In en, this message translates to:
  /// **'Hidden Singles'**
  String get hiddenSingles;

  /// Highlight mistakes setting
  ///
  /// In en, this message translates to:
  /// **'Highlight Mistakes'**
  String get highlightMistakes;

  /// Home button
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Sudoku Game'**
  String get homeTitle;

  /// Home version label
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String homeVersion(Object version);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// Hybrid label (short)
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// Hybrid mode description
  ///
  /// In en, this message translates to:
  /// **'Hybrid Mode: Uses preset region templates with random answers for balanced performance'**
  String get hybridModeDescription;

  /// Jigsaw Sudoku custom game not supported message
  ///
  /// In en, this message translates to:
  /// **'Jigsaw Sudoku does not support custom games yet'**
  String get jigsawCustomNotSupported;

  /// Load game button
  ///
  /// In en, this message translates to:
  /// **'Load Game'**
  String get loadGame;

  /// Delete saved game button
  ///
  /// In en, this message translates to:
  /// **'Delete Saved Game'**
  String get deleteSavedGame;

  /// Delete saved game confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this saved game?'**
  String get deleteSavedGameConfirm;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Mark button
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mark;

  /// Mark cells description
  ///
  /// In en, this message translates to:
  /// **'Mark Cells'**
  String get markCells;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// Mistakes label
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakes;

  /// Music setting
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// Naked pairs/triples exclusion logic
  ///
  /// In en, this message translates to:
  /// **'Naked Pairs/Triples'**
  String get nakedPairsTriples;

  /// New game button
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// Confirmation dialog for new game
  ///
  /// In en, this message translates to:
  /// **'Start New Game?'**
  String get newGameConfirm;

  /// Confirmation dialog content for new game
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new game? Current progress will be lost.'**
  String get newGameConfirmContent;

  /// New record title
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get newRecord;

  /// New record message
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve set a new best record!'**
  String get newRecordMessage;

  /// No games played message
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get noGamesPlayed;

  /// Message when no saved game is found
  ///
  /// In en, this message translates to:
  /// **'No saved game found.'**
  String get noSavedGame;

  /// No statistics message
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get noStatistics;

  /// Not completed
  ///
  /// In en, this message translates to:
  /// **'Not Completed'**
  String get notCompleted;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Played more games
  ///
  /// In en, this message translates to:
  /// **' played more'**
  String get playedMore;

  /// Please wait message
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get pleaseWait;

  /// Puzzle completed message
  ///
  /// In en, this message translates to:
  /// **'Puzzle Completed!'**
  String get puzzleCompleted;

  /// Random label (short)
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// Random mode description
  ///
  /// In en, this message translates to:
  /// **'Random Mode: Uses backtracking algorithm for random generation, different every time'**
  String get randomModeDescription;

  /// Recent games section title
  ///
  /// In en, this message translates to:
  /// **'Recent Games'**
  String get recentGames;

  /// Redo button
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// Region numbers toggle label
  ///
  /// In en, this message translates to:
  /// **'Region Numbers'**
  String get regionNumbers;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Reset game description
  ///
  /// In en, this message translates to:
  /// **'Reset Game'**
  String get resetGame;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Select difficulty title
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// Select Sudoku type title
  ///
  /// In en, this message translates to:
  /// **'Select Sudoku Type'**
  String get selectSudokuType;

  /// Hint for selecting Sudoku type
  ///
  /// In en, this message translates to:
  /// **'Please select a Sudoku type'**
  String get selectSudokuTypeHint;

  /// Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Audio setting
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsAudio;

  /// Auto check setting
  ///
  /// In en, this message translates to:
  /// **'Auto Check'**
  String get settingsAutoCheck;

  /// Basic settings tab
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get settingsBasicSettings;

  /// Advanced strategies setting
  ///
  /// In en, this message translates to:
  /// **'Advanced Strategies'**
  String get settingsAdvancedStrategies;

  /// Game settings
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsGameSettings;

  /// Game settings tab
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get settingsGameSettingsTab;

  /// Hidden pairs/triples setting
  ///
  /// In en, this message translates to:
  /// **'Hidden Pairs/Triples'**
  String get settingsHiddenPairsTriples;

  /// Hidden singles setting
  ///
  /// In en, this message translates to:
  /// **'Hidden Singles'**
  String get settingsHiddenSingles;

  /// Highlight mistakes setting
  ///
  /// In en, this message translates to:
  /// **'Highlight Mistakes'**
  String get settingsHighlightMistakes;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Music setting
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// Naked pairs/triples setting
  ///
  /// In en, this message translates to:
  /// **'Naked Pairs/Triples'**
  String get settingsNakedPairsTriples;

  /// Candidate settings
  ///
  /// In en, this message translates to:
  /// **'Candidate Settings'**
  String get settingsCandidateSettings;

  /// Display mode
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get settingsDisplayMode;

  /// Direct fill display mode
  ///
  /// In en, this message translates to:
  /// **'Direct Fill'**
  String get settingsDisplayModeDirect;

  /// Bubble hint display mode
  ///
  /// In en, this message translates to:
  /// **'Bubble Hint'**
  String get settingsDisplayModeBubble;

  /// Dialog hint display mode
  ///
  /// In en, this message translates to:
  /// **'Dialog Hint'**
  String get settingsDisplayModeDialog;

  /// Hint settings
  ///
  /// In en, this message translates to:
  /// **'Hint Settings'**
  String get settingsHintSettings;

  /// Hint mode
  ///
  /// In en, this message translates to:
  /// **'Hint Mode'**
  String get settingsHintMode;

  /// Direct fill hint mode
  ///
  /// In en, this message translates to:
  /// **'Direct Fill'**
  String get settingsHintModeDirect;

  /// Strategy hint mode
  ///
  /// In en, this message translates to:
  /// **'Strategy Hint'**
  String get settingsHintModeStrategy;

  /// Learning hint mode
  ///
  /// In en, this message translates to:
  /// **'Learning Mode'**
  String get settingsHintModeLearning;

  /// Detailed hint mode
  ///
  /// In en, this message translates to:
  /// **'Detailed Guide'**
  String get settingsHintModeDetailed;

  /// Complete reasoning hint mode
  ///
  /// In en, this message translates to:
  /// **'Complete Reasoning'**
  String get settingsHintModeCompleteReasoning;

  /// Use advanced strategy
  ///
  /// In en, this message translates to:
  /// **'Use Advanced Strategy'**
  String get settingsUseAdvancedStrategy;

  /// Swordfish setting
  ///
  /// In en, this message translates to:
  /// **'Swordfish'**
  String get settingsSwordfish;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// X-Wing setting
  ///
  /// In en, this message translates to:
  /// **'X-Wing'**
  String get settingsXWing;

  /// Show diagonal lines toggle label
  ///
  /// In en, this message translates to:
  /// **'Show Diagonal Lines'**
  String get showDiagonalLines;

  /// Show solution description
  ///
  /// In en, this message translates to:
  /// **'Show Solution'**
  String get showSolution;

  /// Solution button
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// Sound effects setting
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Start game button
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// Start new game description
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get startNewGame;

  /// Statistics exported message
  ///
  /// In en, this message translates to:
  /// **'Statistics exported'**
  String get statisticsExported;

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Game Statistics'**
  String get statisticsTitle;

  /// Summary label
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Sudoku rules title
  ///
  /// In en, this message translates to:
  /// **'Sudoku Rules'**
  String get sudokuRules;

  /// Swordfish exclusion logic
  ///
  /// In en, this message translates to:
  /// **'Swordfish'**
  String get swordfish;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Total games label
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// Undo button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Undo/Redo operation description
  ///
  /// In en, this message translates to:
  /// **'Undo/Redo Operation'**
  String get undoRedoOperation;

  /// Weekly summary title
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// X-Wing exclusion logic
  ///
  /// In en, this message translates to:
  /// **'X-Wing'**
  String get xWing;

  /// Yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Home screen copyright information
  ///
  /// In en, this message translates to:
  /// **'© 2026 Topking Software'**
  String get homeCopyright;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Operation success message
  ///
  /// In en, this message translates to:
  /// **'Operation Successful'**
  String get operationSuccess;

  /// Operation failed message
  ///
  /// In en, this message translates to:
  /// **'Operation Failed'**
  String get operationFailed;

  /// Clear all statistics confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all game statistics? This action cannot be undone.'**
  String get clearAllStatsConfirm;

  /// Statistics cleared message
  ///
  /// In en, this message translates to:
  /// **'All statistics have been cleared'**
  String get statsCleared;

  /// Individual game statistics section title
  ///
  /// In en, this message translates to:
  /// **'Individual Game Statistics'**
  String get individualGameStats;

  /// Incomplete games section title
  ///
  /// In en, this message translates to:
  /// **'Incomplete Games'**
  String get incompleteGames;

  /// Consecutive days label
  ///
  /// In en, this message translates to:
  /// **'Consecutive Days'**
  String get consecutiveDays;

  /// Longest streak label
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No numbers message
  ///
  /// In en, this message translates to:
  /// **'No Numbers'**
  String get noNumbers;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Apply button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Custom Sudoku title
  ///
  /// In en, this message translates to:
  /// **'Custom Sudoku'**
  String get customSudoku;

  /// Custom Sudoku game title
  ///
  /// In en, this message translates to:
  /// **'Custom Sudoku Game'**
  String get customSudokuGame;

  /// Hint message for cell value
  ///
  /// In en, this message translates to:
  /// **'Row {row}, Column {col} should contain {value}'**
  String cellShouldContain(Object row, Object col, Object value);

  /// Row label
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;

  /// Column label
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get col;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
