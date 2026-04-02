import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/games/standard/standard_game_view_model.dart';

void main() {
  group('StandardGameViewModel', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    late StandardGameViewModel viewModel;
    
    setUp(() {
      viewModel = StandardGameViewModel();
    });
    
    tearDown(() {
      viewModel.dispose();
    });
    
    test('should initialize with default state', () {
      expect(viewModel.isPlaying, false);
      expect(viewModel.isCompleted, false);
      expect(viewModel.isLoading, false);
    });
  });
}
