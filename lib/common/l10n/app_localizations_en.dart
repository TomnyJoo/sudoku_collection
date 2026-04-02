// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activeGameTypes => 'Active Game Types';

  @override
  String get appName => 'Sudoku';

  @override
  String get autoMark => 'Auto Mark';

  @override
  String get averageMistakes => 'Average Mistakes';

  @override
  String get averageTime => 'Average Time';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get bestScore => 'Best Score';

  @override
  String get bestTime => 'Best Time';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get clearAllStatsConfirm =>
      'Are you sure you want to clear all statistics?';

  @override
  String get clearBoard => 'Clear Board';

  @override
  String get clearBoardConfirm => 'Are you sure you want to clear the board?';

  @override
  String get clearStatistics => 'Clear Statistics';

  @override
  String get completedGames => 'Completed Games';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get confirm => 'Confirm';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get consecutiveDays => 'Consecutive Days';

  @override
  String get current => 'Current';

  @override
  String get customGame => 'Custom Game';

  @override
  String get customGameError => 'Error creating custom game';

  @override
  String get customGameErrorInvalid =>
      'Invalid Sudoku. Please check your input.';

  @override
  String get customGameErrorMultipleSolutions =>
      'This Sudoku has multiple solutions.';

  @override
  String get customGameErrorTooFew =>
      'Too few numbers entered. Please add more.';

  @override
  String get customGameInstruction1 => 'Enter numbers from 1-9 in the grid.';

  @override
  String get customGameInstruction2 =>
      'Leave empty cells for the puzzle to solve.';

  @override
  String get customSudoku => 'Custom Sudoku';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get difficultyCustom => 'Custom';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyMaster => 'Master';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get erase => 'Erase';

  @override
  String get error => 'Error';

  @override
  String get exportStatistics => 'Export Statistics';

  @override
  String get gameComparison => 'Game Comparison';

  @override
  String get gameRules => 'Game Rules';

  @override
  String get gameTypeDiagonalDescription =>
      'In addition to standard rules, numbers on both main diagonals cannot repeat';

  @override
  String get gameTypeDiagonalName => 'Diagonal Sudoku';

  @override
  String get gameTypeJigsawDescription =>
      'A Sudoku game with irregular regions where numbers cannot repeat within each region';

  @override
  String get gameTypeJigsawName => 'Jigsaw Sudoku';

  @override
  String get gameTypeKillerDescription =>
      'Contains numbers and regions, where the sum of numbers in each region must equal the specified value';

  @override
  String get gameTypeKillerName => 'Killer Sudoku';

  @override
  String get gameTypeSamuraiDescription =>
      'A complex Sudoku game composed of five standard Sudoku puzzles intersecting';

  @override
  String get gameTypeSamuraiName => 'Samurai Sudoku';

  @override
  String get gameTypeStandardDescription =>
      'Classic 9x9 Sudoku game where each row, column, and 3x3 block must contain digits 1-9 without repetition';

  @override
  String get gameTypeStandardName => 'Standard Sudoku';

  @override
  String get gameTypeWindowDescription =>
      'A Sudoku game with four 3x3 window regions where numbers cannot repeat within window regions';

  @override
  String get gameTypeWindowName => 'Window Sudoku';

  @override
  String get generatingGame => 'Generating game, please wait...';

  @override
  String generationFailedError(Object error) {
    return 'Error: $error';
  }

  @override
  String get generationFailedMessage =>
      'Failed to generate game. Please try again.';

  @override
  String get generationFailedTitle => 'Generation Failed';

  @override
  String get hint => 'Hint';

  @override
  String get homeCopyright => '© 2026 Topking Software';

  @override
  String homeVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get incompleteGames => 'Incomplete Games';

  @override
  String get individualGameStats => 'Individual Game Stats';

  @override
  String get loadGame => 'Load Game';

  @override
  String get loading => 'Loading...';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get mark => 'Mark';

  @override
  String get mistakes => 'Mistakes';

  @override
  String get newGame => 'New Game';

  @override
  String get newGameConfirm => 'Start New Game?';

  @override
  String get newGameConfirmContent =>
      'Are you sure you want to start a new game? Current progress will be lost.';

  @override
  String get newRecord => 'New Record!';

  @override
  String get newRecordMessage => 'You have set a new record!';

  @override
  String get noStatistics => 'No statistics available';

  @override
  String get ok => 'OK';

  @override
  String get okButton => 'OK';

  @override
  String get operationFailed => 'Operation Failed';

  @override
  String get operationSuccess => 'Operation Successful';

  @override
  String get overview => 'Overview';

  @override
  String get processing => 'Processing...';

  @override
  String get puzzleCompleted => 'Puzzle Completed';

  @override
  String get redo => 'Redo';

  @override
  String get reset => 'Reset';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get selectSudokuType => 'Select Sudoku Type';

  @override
  String get selectSudokuTypeHint => 'Please select a Sudoku type';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsAutoCheck => 'Auto Check';

  @override
  String get settingsBasicSettings => 'Basic Settings';

  @override
  String get settingsCandidateSettings => 'Candidate Settings';

  @override
  String get settingsGameSettings => 'Game Settings';

  @override
  String get settingsGameSettingsTab => 'Game Settings';

  @override
  String get settingsHighlightMistakes => 'Highlight Mistakes';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUseAdvancedStrategy => 'Use Advanced Strategy';

  @override
  String get solution => 'Solution';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get startNewGame => 'Start New Game';

  @override
  String get statisticsExported => 'Statistics exported successfully';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statsCleared => 'Statistics cleared successfully';

  @override
  String get summary => 'Summary';

  @override
  String get time => 'Time';

  @override
  String get totalGames => 'Total Games';

  @override
  String get undo => 'Undo';
}
