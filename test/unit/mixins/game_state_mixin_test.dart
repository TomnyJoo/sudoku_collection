import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sudoku/common/settings/app_settings.dart';
import 'package:sudoku/core/index.dart';
import '../../helpers/mock_factory.dart';

class TestViewModel extends ChangeNotifier with GameStateMixin, GameAssistMixin {

  TestViewModel(this.gameState, this.gameTimer);
  @override
  GameState gameState;

  @override
  final GameTimer gameTimer;

  @override
  bool get isPlaying => gameState.startTime != null && !gameState.isCompleted;

  @override
  bool get useAdvancedStrategy => true;

  @override
  AppSettings? get settings => null;

  @override
  Future<void> setCellValueForHint(int row, int col, int value) async {}
}

void main() {
  group('GameStateMixin', () {
    late TestViewModel viewModel;
    late GameState gameState;
    late MockGameTimer mockTimer;

    setUp(() {
      mockTimer = MockFactory.createMockGameTimer();
      gameState = GameState(
        board: MockBoard(),
        initialBoard: MockBoard(),
        solution: MockBoard(),
        startTime: DateTime.now(),
        difficulty: 'easy',
      );
      viewModel = TestViewModel(gameState, mockTimer);
    });

    test('should get isPlaying', () {
      expect(viewModel.isPlaying, true);
    });

    test('should get isPaused', () {
      when(() => mockTimer.isPaused).thenReturn(true);
      expect(viewModel.isPaused, true);
    });

    test('should get isCompleted', () {
      expect(viewModel.isCompleted, false);
    });

    test('should toggle mark mode', () async {
      final initialMode = viewModel.isMarkMode;
      await viewModel.toggleMarkMode();
      expect(viewModel.isMarkMode, !initialMode);
    });

    test('should toggle auto mark mode', () async {
      final initialMode = viewModel.isAutoMarkMode;
      await viewModel.toggleAutoMarkMode();
      expect(viewModel.isAutoMarkMode, !initialMode);
    });

    test('should toggle show solution', () async {
      final initialMode = viewModel.showSolution;
      await viewModel.toggleShowSolution();
      expect(viewModel.showSolution, !initialMode);
    });

    test('should reset game', () async {
      await viewModel.resetGame();
      // 验证游戏状态被重置
    });
  });
}

class MockBoard extends Mock implements Board {} 
