import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/standard_game_view_model.dart';

void main() {
  group('Game Flow Tests', () {
    late StandardGameViewModel viewModel;

    setUp(() {
      viewModel = StandardGameViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should complete full game flow', () async {
      // 1. 开始新游戏
      await viewModel.startNewGame(Difficulty.easy);

      // 2. 玩游戏（输入一些数字）
      await viewModel.handleCellTap(0, 0);
      await viewModel.setCellValue(0, 0, 5);
      
      // 3. 暂停游戏
      await viewModel.pauseGame();
      
      // 4. 恢复游戏
      await viewModel.resumeGame();
      
      // 5. 保存游戏
      await viewModel.saveGame();
      
      // 6. 验证游戏状态
      expect(viewModel.isPlaying, true);
    });

    test('should handle interrupt and resume flow', () async {
      // 1. 开始新游戏
      await viewModel.startNewGame(Difficulty.easy);

      // 2. 玩游戏
      await viewModel.handleCellTap(0, 0);
      await viewModel.setCellValue(0, 0, 5);
      
      // 3. 保存游戏
      await viewModel.saveGame();
      
      // 4. 加载游戏
      await viewModel.loadGame();
      
      // 5. 继续游戏
      await viewModel.handleCellTap(0, 1);
      await viewModel.setCellValue(0, 1, 3);
      
      // 6. 验证游戏状态
      expect(viewModel.isPlaying, true);
    });
  });
}
