import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/models/index.dart';
import '../../helpers/mock_objects.dart';

void main() {
  group('GameState', () {
    late GameState gameState;
    late StandardBoard board;
    late StandardBoard solution;
    
    setUp(() {
      board = StandardBoard.empty();
      solution = StandardBoard(size: 9, cells: MockObjects.createFilledCells(MockObjects.createValidSudoku()));
      gameState = StandardGameState(
        board: board,
        initialBoard: board,
        solution: solution,
        difficulty: 'medium',
      );
    });
    
    test('should create game state with default values', () {
      expect(gameState.difficulty, equals('medium'));
      expect(gameState.elapsedTime, equals(0));
      expect(gameState.mistakes, equals(0));
      expect(gameState.isCompleted, isFalse);
      expect(gameState.history.length, equals(1));
      expect(gameState.historyIndex, equals(0));
    });
    
    test('should update board correctly', () {
      final newBoard = board.setCellValue(0, 0, 5);
      final newState = gameState.updateBoard(newBoard);
      
      expect(newState.board.getCell(0, 0).value, equals(5));
      expect(newState.history.length, equals(2));
      expect(newState.historyIndex, equals(1));
    });
    
    test('should limit history size', () {
      var state = gameState;
      
      for (var i = 0; i < 60; i++) {
        final newBoard = state.board.setCellValue(i % 9, (i * 7) % 9, (i % 9) + 1);
        state = state.updateBoard(newBoard);
      }
      
      expect(state.history.length, lessThanOrEqualTo(GameState.maxHistorySize));
    });
    
    test('should undo correctly', () {
      final newBoard1 = board.setCellValue(0, 0, 5);
      var state = gameState.updateBoard(newBoard1);
      
      final newBoard2 = state.board.setCellValue(0, 1, 3);
      state = state.updateBoard(newBoard2);
      
      expect(state.board.getCell(0, 1).value, equals(3));
      
      state = state.undo();
      expect(state.board.getCell(0, 1).value, isNull);
      expect(state.board.getCell(0, 0).value, equals(5));
      
      state = state.undo();
      expect(state.board.getCell(0, 0).value, isNull);
    });
    
    test('should redo correctly', () {
      final newBoard = board.setCellValue(0, 0, 5);
      var state = gameState.updateBoard(newBoard);
      state = state.undo();
      
      expect(state.board.getCell(0, 0).value, isNull);
      
      state = state.redo();
      expect(state.board.getCell(0, 0).value, equals(5));
    });
    
    test('should check canUndo and canRedo correctly', () {
      expect(gameState.canUndo(), isFalse);
      expect(gameState.canRedo(), isFalse);
      
      final newBoard = board.setCellValue(0, 0, 5);
      var state = gameState.updateBoard(newBoard);
      
      expect(state.canUndo(), isTrue);
      expect(state.canRedo(), isFalse);
      
      state = state.undo();
      expect(state.canUndo(), isFalse);
      expect(state.canRedo(), isTrue);
    });
    
    test('should reset game correctly', () {
      final newBoard = board.setCellValue(0, 0, 5);
      var state = gameState.updateBoard(newBoard);
      state = state.copyWith(mistakes: 3, elapsedTime: 100);
      
      state = state.resetGame();
      
      expect(state.board.getCell(0, 0).value, isNull);
      expect(state.mistakes, equals(0));
      expect(state.elapsedTime, equals(0));
      expect(state.isCompleted, isFalse);
      expect(state.history.length, equals(1));
    });
    
    test('should show and hide solution correctly', () {
      final state = gameState.showSolution();
      
      expect(state.isShowingSolution, isTrue);
      expect(state.board.getCell(0, 0).value, isNotNull);
      
      final hiddenState = state.hideSolution();
      expect(hiddenState.isShowingSolution, isFalse);
    });
    
    test('should toggle mark mode correctly', () {
      expect(gameState.isMarkMode, isFalse);
      
      final state = gameState.toggleMarkMode();
      expect(state.isMarkMode, isTrue);
      
      final state2 = state.toggleMarkMode();
      expect(state2.isMarkMode, isFalse);
    });
    
    test('should calculate completion percentage correctly', () {
      expect(gameState.completionPercentage, equals(0.0));
      
      Board newBoard = board;
      for (var i = 0; i < 10; i++) {
        newBoard = newBoard.setCellValue(i ~/ 9, i % 9, (i % 9) + 1);
      }
      final state = gameState.updateBoard(newBoard);
      
      expect(state.completionPercentage, closeTo(10 / 81, 0.01));
    });
    
    test('should get selected cell correctly', () {
      expect(gameState.getSelectedCell(), isNull);
      
      final newBoard = board.selectCell(4, 4);
      final state = gameState.updateBoard(newBoard);
      
      final selectedCell = state.getSelectedCell();
      expect(selectedCell, isNotNull);
      expect(selectedCell!.row, equals(4));
      expect(selectedCell.col, equals(4));
    });
    
    test('should increment mistakes correctly', () {
      final state = gameState.incrementMistakes();
      
      expect(state.mistakes, equals(1));
    });
    
    test('should mark as completed correctly', () {
      final state = gameState.markCompleted();
      
      expect(state.isCompleted, isTrue);
      expect(state.completionTime, isNotNull);
    });
  });
}
