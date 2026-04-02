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

  /// activeGameTypes
  ///
  /// In en, this message translates to:
  /// **'Active Game Types'**
  String get activeGameTypes;

  /// appName
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appName;

  /// autoMark
  ///
  /// In en, this message translates to:
  /// **'Auto Mark'**
  String get autoMark;

  /// averageMistakes
  ///
  /// In en, this message translates to:
  /// **'Average Mistakes'**
  String get averageMistakes;

  /// averageTime
  ///
  /// In en, this message translates to:
  /// **'Average Time'**
  String get averageTime;

  /// backToMenu
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// bestScore
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// bestTime
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// clearAllStatsConfirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all statistics?'**
  String get clearAllStatsConfirm;

  /// clearBoard
  ///
  /// In en, this message translates to:
  /// **'Clear Board'**
  String get clearBoard;

  /// clearBoardConfirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the board?'**
  String get clearBoardConfirm;

  /// clearStatistics
  ///
  /// In en, this message translates to:
  /// **'Clear Statistics'**
  String get clearStatistics;

  /// completedGames
  ///
  /// In en, this message translates to:
  /// **'Completed Games'**
  String get completedGames;

  /// completionRate
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// congratulations
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// consecutiveDays
  ///
  /// In en, this message translates to:
  /// **'Consecutive Days'**
  String get consecutiveDays;

  /// current
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// customGame
  ///
  /// In en, this message translates to:
  /// **'Custom Game'**
  String get customGame;

  /// customGameError
  ///
  /// In en, this message translates to:
  /// **'Error creating custom game'**
  String get customGameError;

  /// customGameErrorInvalid
  ///
  /// In en, this message translates to:
  /// **'Invalid Sudoku. Please check your input.'**
  String get customGameErrorInvalid;

  /// customGameErrorMultipleSolutions
  ///
  /// In en, this message translates to:
  /// **'This Sudoku has multiple solutions.'**
  String get customGameErrorMultipleSolutions;

  /// customGameErrorTooFew
  ///
  /// In en, this message translates to:
  /// **'Too few numbers entered. Please add more.'**
  String get customGameErrorTooFew;

  /// customGameInstruction1
  ///
  /// In en, this message translates to:
  /// **'Enter numbers from 1-9 in the grid.'**
  String get customGameInstruction1;

  /// customGameInstruction2
  ///
  /// In en, this message translates to:
  /// **'Leave empty cells for the puzzle to solve.'**
  String get customGameInstruction2;

  /// customSudoku
  ///
  /// In en, this message translates to:
  /// **'Custom Sudoku'**
  String get customSudoku;

  /// difficulty
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// difficultyBeginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get difficultyBeginner;

  /// difficultyCustom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get difficultyCustom;

  /// difficultyEasy
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// difficultyExpert
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyExpert;

  /// difficultyHard
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// difficultyMaster
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get difficultyMaster;

  /// difficultyMedium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// erase
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get erase;

  /// error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// exportStatistics
  ///
  /// In en, this message translates to:
  /// **'Export Statistics'**
  String get exportStatistics;

  /// gameComparison
  ///
  /// In en, this message translates to:
  /// **'Game Comparison'**
  String get gameComparison;

  /// gameRules
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get gameRules;

  /// gameTypeDiagonalDescription
  ///
  /// In en, this message translates to:
  /// **'In addition to standard rules, numbers on both main diagonals cannot repeat'**
  String get gameTypeDiagonalDescription;

  /// gameTypeDiagonalName
  ///
  /// In en, this message translates to:
  /// **'Diagonal Sudoku'**
  String get gameTypeDiagonalName;

  /// gameTypeJigsawDescription
  ///
  /// In en, this message translates to:
  /// **'A Sudoku game with irregular regions where numbers cannot repeat within each region'**
  String get gameTypeJigsawDescription;

  /// gameTypeJigsawName
  ///
  /// In en, this message translates to:
  /// **'Jigsaw Sudoku'**
  String get gameTypeJigsawName;

  /// gameTypeKillerDescription
  ///
  /// In en, this message translates to:
  /// **'Contains numbers and regions, where the sum of numbers in each region must equal the specified value'**
  String get gameTypeKillerDescription;

  /// gameTypeKillerName
  ///
  /// In en, this message translates to:
  /// **'Killer Sudoku'**
  String get gameTypeKillerName;

  /// gameTypeSamuraiDescription
  ///
  /// In en, this message translates to:
  /// **'A complex Sudoku game composed of five standard Sudoku puzzles intersecting'**
  String get gameTypeSamuraiDescription;

  /// gameTypeSamuraiName
  ///
  /// In en, this message translates to:
  /// **'Samurai Sudoku'**
  String get gameTypeSamuraiName;

  /// gameTypeStandardDescription
  ///
  /// In en, this message translates to:
  /// **'Classic 9x9 Sudoku game where each row, column, and 3x3 block must contain digits 1-9 without repetition'**
  String get gameTypeStandardDescription;

  /// gameTypeStandardName
  ///
  /// In en, this message translates to:
  /// **'Standard Sudoku'**
  String get gameTypeStandardName;

  /// gameTypeWindowDescription
  ///
  /// In en, this message translates to:
  /// **'A Sudoku game with four 3x3 window regions where numbers cannot repeat within window regions'**
  String get gameTypeWindowDescription;

  /// gameTypeWindowName
  ///
  /// In en, this message translates to:
  /// **'Window Sudoku'**
  String get gameTypeWindowName;

  /// generatingGame
  ///
  /// In en, this message translates to:
  /// **'Generating game, please wait...'**
  String get generatingGame;

  /// generationFailedError
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String generationFailedError(Object error);

  /// generationFailedMessage
  ///
  /// In en, this message translates to:
  /// **'Failed to generate game. Please try again.'**
  String get generationFailedMessage;

  /// generationFailedTitle
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get generationFailedTitle;

  /// hint
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// homeCopyright
  ///
  /// In en, this message translates to:
  /// **'© 2026 Topking Software'**
  String get homeCopyright;

  /// homeVersion
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String homeVersion(Object version);

  /// incompleteGames
  ///
  /// In en, this message translates to:
  /// **'Incomplete Games'**
  String get incompleteGames;

  /// individualGameStats
  ///
  /// In en, this message translates to:
  /// **'Individual Game Stats'**
  String get individualGameStats;

  /// loadGame
  ///
  /// In en, this message translates to:
  /// **'Load Game'**
  String get loadGame;

  /// loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// longestStreak
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// mark
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mark;

  /// mistakes
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakes;

  /// newGame
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// newGameConfirm
  ///
  /// In en, this message translates to:
  /// **'Start New Game?'**
  String get newGameConfirm;

  /// newGameConfirmContent
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new game? Current progress will be lost.'**
  String get newGameConfirmContent;

  /// newRecord
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get newRecord;

  /// newRecordMessage
  ///
  /// In en, this message translates to:
  /// **'You have set a new record!'**
  String get newRecordMessage;

  /// noStatistics
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get noStatistics;

  /// ok
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// okButton
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// operationFailed
  ///
  /// In en, this message translates to:
  /// **'Operation Failed'**
  String get operationFailed;

  /// operationSuccess
  ///
  /// In en, this message translates to:
  /// **'Operation Successful'**
  String get operationSuccess;

  /// overview
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// processing
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// puzzleCompleted
  ///
  /// In en, this message translates to:
  /// **'Puzzle Completed'**
  String get puzzleCompleted;

  /// redo
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// selectDifficulty
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// selectSudokuType
  ///
  /// In en, this message translates to:
  /// **'Select Sudoku Type'**
  String get selectSudokuType;

  /// selectSudokuTypeHint
  ///
  /// In en, this message translates to:
  /// **'Please select a Sudoku type'**
  String get selectSudokuTypeHint;

  /// settingsAudio
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsAudio;

  /// settingsAutoCheck
  ///
  /// In en, this message translates to:
  /// **'Auto Check'**
  String get settingsAutoCheck;

  /// settingsBasicSettings
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get settingsBasicSettings;

  /// settingsCandidateSettings
  ///
  /// In en, this message translates to:
  /// **'Candidate Settings'**
  String get settingsCandidateSettings;

  /// settingsGameSettings
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get settingsGameSettings;

  /// settingsGameSettingsTab
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get settingsGameSettingsTab;

  /// settingsHighlightMistakes
  ///
  /// In en, this message translates to:
  /// **'Highlight Mistakes'**
  String get settingsHighlightMistakes;

  /// settingsLanguage
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// settingsMusic
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// settingsTheme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// settingsThemeDark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// settingsThemeLight
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// settingsTitle
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// settingsUseAdvancedStrategy
  ///
  /// In en, this message translates to:
  /// **'Use Advanced Strategy'**
  String get settingsUseAdvancedStrategy;

  /// solution
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// soundEffects
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// startNewGame
  ///
  /// In en, this message translates to:
  /// **'Start New Game'**
  String get startNewGame;

  /// statisticsExported
  ///
  /// In en, this message translates to:
  /// **'Statistics exported successfully'**
  String get statisticsExported;

  /// statisticsTitle
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// statsCleared
  ///
  /// In en, this message translates to:
  /// **'Statistics cleared successfully'**
  String get statsCleared;

  /// summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// totalGames
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;
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
