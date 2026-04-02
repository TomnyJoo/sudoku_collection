import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/games/standard/models/standard_board.dart';
import '../../helpers/mock_objects.dart';

void main() {
  group('Board', () {
    late StandardBoard board;
    
    setUp(() {
      board = StandardBoard.empty();
    });
    
    test('should create empty board', () {
      expect(board.size, equals(9));
      expect(board.cells.length, equals(9));
      expect(board.cells[0].length, equals(9));
      
      for (final row in board.cells) {
        for (final cell in row) {
          expect(cell.isEmpty, isTrue);
        }
      }
    });
    
    test('should get cell correctly', () {
      board = StandardBoard(size: 9, cells: MockObjects.createEmptyCells(9));
      final cell = board.getCell(4, 5);
      
      expect(cell.row, equals(4));
      expect(cell.col, equals(5));
    });
    
    test('should throw on invalid cell access', () {
      expect(() => board.getCell(-1, 0), throwsRangeError);
      expect(() => board.getCell(9, 0), throwsRangeError);
      expect(() => board.getCell(0, 9), throwsRangeError);
    });
    
    test('should set cell value correctly', () {
      final newBoard = board.setCellValue(0, 0, 5);
      
      expect(newBoard.getCell(0, 0).value, equals(5));
      expect(board.getCell(0, 0).value, isNull);
    });
    
    test('should not set value on fixed cell', () {
      final cells = MockObjects.createEmptyCells(9);
      cells[0][0] = MockObjects.createCell(value: 5, isFixed: true);
      board = StandardBoard(size: 9, cells: cells);
      
      final newBoard = board.setCellValue(0, 0, 7);
      
      expect(newBoard.getCell(0, 0).value, equals(5));
    });
    
    test('should select cell correctly', () {
      final newBoard = board.selectCell(4, 4);
      
      expect(newBoard.getCell(4, 4).isSelected, isTrue);
      
      var selectedCount = 0;
      for (final row in newBoard.cells) {
        for (final cell in row) {
          if (cell.isSelected) selectedCount++;
        }
      }
      expect(selectedCount, equals(1));
    });
    
    test('should highlight related cells on selection', () {
      final newBoard = board.selectCell(4, 4);
      
      for (var col = 0; col < 9; col++) {
        if (col != 4) {
          expect(newBoard.getCell(4, col).isHighlighted, isTrue, reason: 'Row 4, col $col should be highlighted');
        }
      }
      
      for (var row = 0; row < 9; row++) {
        if (row != 4) {
          expect(newBoard.getCell(row, 4).isHighlighted, isTrue, reason: 'Row $row, col 4 should be highlighted');
        }
      }
    });
    
    test('should get empty cells correctly', () {
      final cells = MockObjects.createEmptyCells(9);
      cells[0][0] = MockObjects.createCell(value: 5);
      cells[1][1] = MockObjects.createCell(row: 1, col: 1, value: 3);
      board = StandardBoard(size: 9, cells: cells);
      
      final emptyCells = board.getEmptyCells();
      
      expect(emptyCells.length, equals(81 - 2));
    });
    
    test('should get filled cells correctly', () {
      final cells = MockObjects.createEmptyCells(9);
      cells[0][0] = MockObjects.createCell(value: 5);
      cells[1][1] = MockObjects.createCell(row: 1, col: 1, value: 3);
      board = StandardBoard(size: 9, cells: cells);
      
      final filledCells = board.getFilledCells();
      
      expect(filledCells.length, equals(2));
    });
    
    test('should calculate number counts correctly', () {
      final cells = MockObjects.createEmptyCells(9);
      cells[0][0] = MockObjects.createCell(value: 5);
      cells[0][1] = MockObjects.createCell(col: 1, value: 5);
      cells[1][0] = MockObjects.createCell(row: 1, value: 3);
      board = StandardBoard(size: 9, cells: cells);
      
      final counts = board.calculateNumberCounts();
      
      expect(counts[5], equals(2));
      expect(counts[3], equals(1));
    });
    
    test('should check completion correctly', () {
      expect(board.isComplete(), isFalse);
      
      final validSudoku = MockObjects.createValidSudoku();
      final cells = MockObjects.createFilledCells(validSudoku);
      board = StandardBoard(size: 9, cells: cells);
      
      expect(board.isComplete(), isTrue);
    });
    
    test('should serialize to JSON correctly', () {
      board = StandardBoard.empty();
      final json = board.toJson();
      
      expect(json['size'], equals(9));
      expect(json['cells'], isA<List>());
      expect((json['cells'] as List).length, equals(9));
    });
  });
}
