import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import '../../helpers/mock_objects.dart';

void main() {
  group('GameValidator', () {
    late GameValidator validator;
    
    setUp(() {
      validator = GameValidator();
    });
    
    test('should validate empty board', () {
      final board = StandardBoard.empty();
      
      expect(validator.validateBoard(board), isTrue);
    });
    
    test('should validate valid sudoku', () {
      final validSudoku = MockObjects.createValidSudoku();
      final board = _createBoardWithValues(validSudoku);
      
      expect(validator.validateBoard(board), isTrue);
    });
    
    test('should detect invalid row', () {
      final values = MockObjects.createValidSudoku();
      values[0][0] = 6;
      values[0][1] = 6;
      final board = _createBoardWithValues(values);
      
      expect(validator.validateBoard(board), isFalse);
    });
    
    test('should detect invalid column', () {
      final values = MockObjects.createValidSudoku();
      values[0][0] = 6;
      values[1][0] = 6;
      final board = _createBoardWithValues(values);
      
      expect(validator.validateBoard(board), isFalse);
    });
    
    test('should detect invalid region', () {
      final values = MockObjects.createValidSudoku();
      values[0][0] = 6;
      values[1][1] = 6;
      final board = _createBoardWithValues(values);
      
      expect(validator.validateBoard(board), isFalse);
    });
    
    test('should check valid move correctly', () {
      final board = StandardBoard.empty();
      
      expect(validator.isValidMove(board, 0, 0, 5), isTrue);
      
      final values = List<List<int?>>.generate(9, (row) => List.generate(9, (col) => null));
      values[0][1] = 5;
      final boardWithConflict = _createBoardWithValues(values);
      
      expect(validator.isValidMove(boardWithConflict, 0, 0, 5), isFalse);
    });
    
    test('should check game completion correctly', () {
      final emptyBoard = StandardBoard.empty();
      expect(validator.isGameCompleted(emptyBoard), isFalse);
      
      final validSudoku = MockObjects.createValidSudoku();
      final completeBoard = _createBoardWithValues(validSudoku);
      expect(validator.isGameCompleted(completeBoard), isTrue);
    });
    
    test('should detect duplicates correctly', () {
      final board = StandardBoard.empty();
      expect(validator.hasDuplicates(board), isFalse);
      
      final values = List<List<int?>>.generate(9, (row) => List.generate(9, (col) => null));
      values[0][0] = 5;
      values[0][1] = 5;
      final invalidBoard = _createBoardWithValues(values);
      expect(validator.hasDuplicates(invalidBoard), isTrue);
    });
  });
}

StandardBoard _createBoardWithValues(List<List<int?>> values) {
  final cells = MockObjects.createFilledCells(values);
  final board = StandardBoard(size: 9, cells: cells);
  return StandardBoard(size: 9, cells: cells, regions: board.createRegions());
}
