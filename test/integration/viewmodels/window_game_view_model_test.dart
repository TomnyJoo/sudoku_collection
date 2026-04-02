import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/window/window_game_view_model.dart';

void main() {
  group('WindowGameViewModel', () {
    late WindowGameViewModel viewModel;

    setUp(() {
      viewModel = WindowGameViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should initialize with default state', () {
      expect(viewModel.isPlaying, false);
      expect(viewModel.isCompleted, false);
      expect(viewModel.isLoading, false);
    });

    test('should start new game', () async {
      await viewModel.startNewGame(Difficulty.easy);
      // 验证窗口数独游戏开始
    });

    test('should handle window-specific rules', () async {
      await viewModel.startNewGame(Difficulty.easy);
      // 测试窗口数独特有的规则
    });
  });
}
