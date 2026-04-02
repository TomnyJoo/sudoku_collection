import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/difficulty.dart';
import 'package:sudoku/core/services/game_validator.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import 'package:sudoku/games/standard/standard_game_service.dart';

void main() {
  group('StandardGameService', () {
    late StandardGameService service;
    
    setUp(() {
      service = StandardGameService();
    });
    
    test('should create game state', () {
      final puzzle = StandardBoard.empty();
      final solution = StandardBoard.empty();
      
      final gameState = service.createGameState(
        puzzle: puzzle,
        solution: solution,
        difficulty: Difficulty.easy,
      );
      
      expect(gameState, isNotNull);
      expect(gameState.board.size, 9);
      expect(gameState.difficulty, Difficulty.easy.name);
    });
    
    test('should validate correct move', () {
      final board = StandardBoard.empty();
      final validator = GameValidator();
      final result = validator.isValidMove(board, 0, 0, 5);
      expect(result, isTrue);
    });
    
    test('should detect invalid move', () {
      var board = StandardBoard.empty();
      board = board.setCellValue(0, 1, 5) as StandardBoard;
      final validator = GameValidator();
      final result = validator.isValidMove(board, 0, 0, 5);
      expect(result, isFalse);
    });
  });
}
