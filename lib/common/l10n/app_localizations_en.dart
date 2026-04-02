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
  String get advancedExclusion => 'Advanced Exclusion Logic';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get appName => 'Sudoku';

  @override
  String get autoCheck => 'Auto Check';

  @override
  String get autoMark => 'Auto Mark';

  @override
  String get autoMarkPossibilities => 'Auto Mark Possibilities';

  @override
  String get autoSave => 'Auto Save';

  @override
  String get averageMistakes => 'Average Mistakes';

  @override
  String get averageTime => 'Average Time';

  @override
  String get backToMenu => 'Back';

  @override
  String get basicSettings => 'Basic Settings';

  @override
  String get bestScore => 'Best Score';

  @override
  String get bestScoreRule =>
      'Record rule: shorter time, or same time with fewer mistakes';

  @override
  String get bestTime => 'Best Time';

  @override
  String get better => 'Better';

  @override
  String get blockExclusion => 'Block Exclusion';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get clearBestScores => 'Clear Best Scores';

  @override
  String get clearBoard => 'Clear Board';

  @override
  String get clearBoardConfirm => 'Are you sure you want to clear the board?';

  @override
  String get clearCell => 'Clear Cell';

  @override
  String get clearStatistics => 'Clear Statistics';

  @override
  String get clearStatisticsConfirmMessage =>
      'Are you sure you want to clear all statistics? This action cannot be undone.';

  @override
  String get clearStatisticsConfirmTitle => 'Confirm Clear Statistics';

  @override
  String get combinedStatistics => 'Combined Statistics';

  @override
  String get completed => 'Completed';

  @override
  String get completedGames => 'Completed Games';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get confirm => 'Confirm';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get current => 'Current';

  @override
  String get customDifficulty => 'Custom Difficulty';

  @override
  String get customGame => 'Custom Game';

  @override
  String get customGameError => 'Error';

  @override
  String get customGameErrorInvalid =>
      'Invalid board: some numbers conflict with each other.';

  @override
  String get customGameErrorMultipleSolutions =>
      'This board has multiple solutions. Please add more numbers.';

  @override
  String get customGameErrorTooFew => 'Please fill at least 17 cells.';

  @override
  String get customGameInstruction1 => 'Tap a cell to select it';

  @override
  String get customGameInstruction2 => 'Use the number pad to fill in numbers';

  @override
  String get customGameInstruction3 => 'Tap the same number to delete it';

  @override
  String get customGameInstruction4 => 'Tap \"Start Game\" when finished';

  @override
  String get customGameInstructions => 'Custom Game Instructions';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get daysAgo => 'days ago';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get difficultyCustom => 'Custom';

  @override
  String get difficultyDistribution => 'Difficulty Distribution';

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
  String get difficultyPerformance => 'Difficulty Performance';

  @override
  String get difficultyStatistics => 'Difficulty Statistics';

  @override
  String get efficient => 'Efficient';

  @override
  String get efficientModeDescription =>
      'Efficient Mode: Uses preset templates for fast generation with stable quality';

  @override
  String get equalGamesPlayed => 'Both games played equally';

  @override
  String get erase => 'Erase';

  @override
  String get error => 'Error';

  @override
  String get exportFailed => 'Failed to export statistics';

  @override
  String get exportStatistics => 'Export Statistics';

  @override
  String get gameComparison => 'Game Comparison';

  @override
  String get gameCompletionRate => 'Game Completion Rate';

  @override
  String gameDifficulty(Object level) {
    return 'Difficulty: $level';
  }

  @override
  String gameMistakes(Object count) {
    return 'Mistakes: $count';
  }

  @override
  String get gameRules => 'Game Rules';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String gameTime(Object time) {
    return 'Time: $time';
  }

  @override
  String get gameTrends => 'Game Trends';

  @override
  String get gameTypeCustomDescription =>
      'A fully customizable Sudoku game where you can set any rules and regions';

  @override
  String get gameTypeCustomName => 'Custom Sudoku';

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
  String get generator => 'Generator';

  @override
  String get getHint => 'Get Hint';

  @override
  String get help => 'Help';

  @override
  String get hint => 'Hint';

  @override
  String get hiddenPairsTriples => 'Hidden Pairs/Triples';

  @override
  String get hiddenSingles => 'Hidden Singles';

  @override
  String get highlightMistakes => 'Highlight Mistakes';

  @override
  String get home => 'Home';

  @override
  String get homeTitle => 'Sudoku Game';

  @override
  String homeVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get hybridModeDescription =>
      'Hybrid Mode: Uses preset region templates with random answers for balanced performance';

  @override
  String get jigsawCustomNotSupported =>
      'Jigsaw Sudoku does not support custom games yet';

  @override
  String get loadGame => 'Load Game';

  @override
  String get deleteSavedGame => 'Delete Saved Game';

  @override
  String get deleteSavedGameConfirm =>
      'Are you sure you want to delete this saved game?';

  @override
  String get delete => 'Delete';

  @override
  String get mark => 'Mark';

  @override
  String get markCells => 'Mark Cells';

  @override
  String get minutesAgo => 'minutes ago';

  @override
  String get mistakes => 'Mistakes';

  @override
  String get music => 'Music';

  @override
  String get nakedPairsTriples => 'Naked Pairs/Triples';

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
  String get newRecordMessage =>
      'Congratulations! You\'ve set a new best record!';

  @override
  String get noGamesPlayed => 'No games played yet';

  @override
  String get noSavedGame => 'No saved game found.';

  @override
  String get noStatistics => 'No statistics available';

  @override
  String get notCompleted => 'Not Completed';

  @override
  String get ok => 'OK';

  @override
  String get okButton => 'OK';

  @override
  String get overview => 'Overview';

  @override
  String get playedMore => ' played more';

  @override
  String get pleaseWait => 'Please Wait';

  @override
  String get puzzleCompleted => 'Puzzle Completed!';

  @override
  String get random => 'Random';

  @override
  String get randomModeDescription =>
      'Random Mode: Uses backtracking algorithm for random generation, different every time';

  @override
  String get recentGames => 'Recent Games';

  @override
  String get redo => 'Redo';

  @override
  String get regionNumbers => 'Region Numbers';

  @override
  String get reset => 'Reset';

  @override
  String get resetGame => 'Reset Game';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get selectSudokuType => 'Select Sudoku Type';

  @override
  String get selectSudokuTypeHint => 'Please select a Sudoku type';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsAutoCheck => 'Auto Check';

  @override
  String get settingsBasicSettings => 'Basic Settings';

  @override
  String get settingsAdvancedStrategies => 'Advanced Strategies';

  @override
  String get settingsGameSettings => 'General Settings';

  @override
  String get settingsGameSettingsTab => 'Game Settings';

  @override
  String get settingsHiddenPairsTriples => 'Hidden Pairs/Triples';

  @override
  String get settingsHiddenSingles => 'Hidden Singles';

  @override
  String get settingsHighlightMistakes => 'Highlight Mistakes';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsNakedPairsTriples => 'Naked Pairs/Triples';

  @override
  String get settingsCandidateSettings => 'Candidate Settings';

  @override
  String get settingsDisplayMode => 'Display Mode';

  @override
  String get settingsDisplayModeDirect => 'Direct Fill';

  @override
  String get settingsDisplayModeBubble => 'Bubble Hint';

  @override
  String get settingsDisplayModeDialog => 'Dialog Hint';

  @override
  String get settingsHintSettings => 'Hint Settings';

  @override
  String get settingsHintMode => 'Hint Mode';

  @override
  String get settingsHintModeDirect => 'Direct Fill';

  @override
  String get settingsHintModeStrategy => 'Strategy Hint';

  @override
  String get settingsHintModeLearning => 'Learning Mode';

  @override
  String get settingsHintModeDetailed => 'Detailed Guide';

  @override
  String get settingsHintModeCompleteReasoning => 'Complete Reasoning';

  @override
  String get settingsUseAdvancedStrategy => 'Use Advanced Strategy';

  @override
  String get settingsSwordfish => 'Swordfish';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsXWing => 'X-Wing';

  @override
  String get showDiagonalLines => 'Show Diagonal Lines';

  @override
  String get showSolution => 'Show Solution';

  @override
  String get solution => 'Solution';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get startGame => 'Start Game';

  @override
  String get startNewGame => 'New Game';

  @override
  String get statisticsExported => 'Statistics exported';

  @override
  String get statisticsTitle => 'Game Statistics';

  @override
  String get summary => 'Summary';

  @override
  String get sudokuRules => 'Sudoku Rules';

  @override
  String get swordfish => 'Swordfish';

  @override
  String get time => 'Time';

  @override
  String get totalGames => 'Total Games';

  @override
  String get undo => 'Undo';

  @override
  String get undoRedoOperation => 'Undo/Redo Operation';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get xWing => 'X-Wing';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get homeCopyright => '© 2026 Topking Software';

  @override
  String get loading => 'Loading...';

  @override
  String get processing => 'Processing...';

  @override
  String get operationSuccess => 'Operation Successful';

  @override
  String get operationFailed => 'Operation Failed';

  @override
  String get clearAllStatsConfirm =>
      'Are you sure you want to clear all game statistics? This action cannot be undone.';

  @override
  String get statsCleared => 'All statistics have been cleared';

  @override
  String get individualGameStats => 'Individual Game Statistics';

  @override
  String get incompleteGames => 'Incomplete Games';

  @override
  String get consecutiveDays => 'Consecutive Days';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get noNumbers => 'No Numbers';

  @override
  String get close => 'Close';

  @override
  String get apply => 'Apply';

  @override
  String get customSudoku => 'Custom Sudoku';

  @override
  String get customSudokuGame => 'Custom Sudoku Game';

  @override
  String cellShouldContain(Object row, Object col, Object value) {
    return 'Row $row, Column $col should contain $value';
  }

  @override
  String get row => 'Row';

  @override
  String get col => 'Column';
}
