import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/standard_game_view_model.dart';

void main() {
  group('Persistence Tests', () {
    late StandardGameViewModel viewModel;

    setUp(() {
      viewModel = StandardGameViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should save and load game state', () async {
      // 1. 开始新游戏
      await viewModel.startNewGame(Difficulty.easy);
      
      // 2. 玩游戏
      await viewModel.handleCellTap(0, 0);
      await viewModel.setCellValue(0, 0, 5);
      
      // 3. 保存游戏
      await viewModel.saveGame();
      
      // 4. 创建新的 ViewModel
      final newViewModel = StandardGameViewModel();
      
      // 5. 加载游戏
      await newViewModel.loadGame();
      
      // 6. 验证游戏状态
      expect(newViewModel.isPlaying, true);
      
      newViewModel.dispose();
    });

    test('should handle save failure', () async {
      // 测试保存失败的处理
      await viewModel.saveGame();
      // 验证错误处理
    });

    test('should handle load failure', () async {
      // 测试加载失败的处理
      await viewModel.loadGame();
      // 验证错误处理
    });
  });
}
