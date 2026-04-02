import 'package:mocktail/mocktail.dart';
import 'package:sudoku/core/index.dart';

class MockGameService extends Mock implements GameService {} 
class MockGameTimer extends Mock implements GameTimer {} 

class MockFactory {
  static MockGameService createMockGameService() {
    final mock = MockGameService();
    when(() => mock.gameType).thenReturn('standard');
    return mock;
  }

  static MockGameTimer createMockGameTimer() {
    final mock = MockGameTimer();
    when(() => mock.isRunning).thenReturn(false);
    when(() => mock.isPaused).thenReturn(false);
    when(() => mock.isCompleted).thenReturn(false);
    when(() => mock.elapsedTime).thenReturn(0);
    return mock;
  }
}
