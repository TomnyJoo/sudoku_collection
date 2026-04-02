import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/index.dart';
import '../../helpers/mock_objects.dart';

void main() {
  group('Cell', () {
    test('should create cell with default values', () {
      const cell = Cell(row: 0, col: 0);
      
      expect(cell.row, equals(0));
      expect(cell.col, equals(0));
      expect(cell.value, isNull);
      expect(cell.isFixed, isFalse);
      expect(cell.candidates, isEmpty);
      expect(cell.isSelected, isFalse);
      expect(cell.isHighlighted, isFalse);
      expect(cell.isError, isFalse);
    });
    
    test('should create cell with value', () {
      final cell = MockObjects.createCell(value: 5, isFixed: true);
      
      expect(cell.value, equals(5));
      expect(cell.isFixed, isTrue);
      expect(cell.isEditable, isFalse);
    });
    
    test('should correctly identify empty cell', () {
      final emptyCell = MockObjects.createCell();
      final filledCell = MockObjects.createCell(value: 5);
      
      expect(emptyCell.isEmpty, isTrue);
      expect(filledCell.isEmpty, isFalse);
    });
    
    test('should set value correctly', () {
      final cell = MockObjects.createCell();
      final newCell = cell.setValue(7);
      
      expect(newCell.value, equals(7));
      expect(newCell.candidates, isEmpty);
      expect(cell.value, isNull);
    });
    
    test('should add candidate correctly', () {
      final cell = MockObjects.createCell();
      final newCell = cell.addCandidate(5);
      
      expect(newCell.candidates, contains(5));
    });
    
    test('should remove candidate correctly', () {
      final cell = MockObjects.createCell(candidates: {1, 2, 3});
      final newCell = cell.removeCandidate(2);
      
      expect(newCell.candidates, equals({1, 3}));
    });
    
    test('should toggle candidate correctly', () {
      final cell = MockObjects.createCell(candidates: {1, 2});
      
      final cellWithAdded = cell.toggleCandidate(3);
      expect(cellWithAdded.candidates, equals({1, 2, 3}));
      
      final cellWithRemoved = cellWithAdded.toggleCandidate(2);
      expect(cellWithRemoved.candidates, equals({1, 3}));
    });
    
    test('should clear cell correctly', () {
      final cell = MockObjects.createCell(value: 5, candidates: {1, 2, 3});
      final clearedCell = cell.clear();
      
      expect(clearedCell.value, isNull);
      expect(clearedCell.candidates, isEmpty);
    });
    
    test('should copy with new values', () {
      final cell = MockObjects.createCell(value: 5);
      final copiedCell = cell.copyWith(value: 7, isSelected: true);
      
      expect(copiedCell.value, equals(7));
      expect(copiedCell.isSelected, isTrue);
      expect(cell.value, equals(5));
    });
    
    test('should serialize to JSON correctly', () {
      final cell = MockObjects.createCell(
        value: 5,
        isFixed: true,
        candidates: {1, 2, 3},
      );
      final json = cell.toJson();
      
      expect(json['row'], equals(0));
      expect(json['col'], equals(0));
      expect(json['value'], equals(5));
      expect(json['isFixed'], isTrue);
      expect(json['candidates'], equals([1, 2, 3]));
    });
    
    test('should deserialize from JSON correctly', () {
      final json = {
        'row': 1,
        'col': 2,
        'value': 7,
        'isFixed': true,
        'candidates': [4, 5, 6],
        'isSelected': false,
        'isHighlighted': false,
        'isError': false,
      };
      final cell = Cell.fromJson(json);
      
      expect(cell.row, equals(1));
      expect(cell.col, equals(2));
      expect(cell.value, equals(7));
      expect(cell.isFixed, isTrue);
      expect(cell.candidates, equals({4, 5, 6}));
    });
  });
}
