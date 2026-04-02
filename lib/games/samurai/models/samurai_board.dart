// ignore_for_file: use_super_parameters

import 'package:sudoku/core/models/index.dart';

class SamuraiBoard extends Board {

  factory SamuraiBoard({
    required List<List<Cell>> cells,
    List<Region>? regions,
  }) {
    regions ??= _createRegions(cells);
    return SamuraiBoard._internal(cells: cells, regions: regions);
  }

  factory SamuraiBoard.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List;
    final cells = cellsJson.map((row) => (row as List).map((cellJson) => Cell.fromJson(cellJson)).toList()).toList();

    final regionsJson = json['regions'] as List?;
    if (regionsJson != null && regionsJson.isNotEmpty) {
      final regions = regionsJson.map((r) => Region.fromJson(r)).toList();
      return SamuraiBoard(cells: cells, regions: regions);
    }
    return SamuraiBoard(cells: cells); // 自动生成 regions
  }

  SamuraiBoard._internal({
    required List<List<Cell>> cells,
    required List<Region> regions,
  })  : assert(regions.isNotEmpty, 'Regions must not be empty'),
       super(
         size: boardSize,
         cells: cells,
         regions: regions,
       );
  static const int boardSize = 21;
  static const int subGridSize = 9;

  static const List<(int, int)> subGridOffsets = [
    (0, 0),      // 左上
    (0, 12),     // 右上
    (12, 0),     // 左下
    (12, 12),    // 右下
    (6, 6),      // 中心
  ];

  static List<Region> _createRegions(List<List<Cell>> cells) {
    final regions = <Region>[];
    for (int i = 0; i < 5; i++) {
      final (startRow, startCol) = subGridOffsets[i];
      regions.addAll(_createSubGridRegions(cells, startRow, startCol, i));
    }
    assert(regions.length == 135, 'Expected 135 regions, got ${regions.length}');
    return regions;
  }

  static List<Region> _createSubGridRegions(
      List<List<Cell>> cells, int startRow, int startCol, int subGridIndex) {
    final regions = <Region>[];

    // 行区域（使用全局坐标）
    for (int row = 0; row < subGridSize; row++) {
      final rowCells = <Cell>[];
      for (int col = 0; col < subGridSize; col++) {
        rowCells.add(cells[startRow + row][startCol + col]);
      }
      regions.add(Region(
        id: 'subgrid_${subGridIndex}_row_$row',
        type: RegionType.row,
        name: 'SubGrid $subGridIndex Row $row',
        cells: rowCells,
      ));
    }

    // 列区域
    for (int col = 0; col < subGridSize; col++) {
      final colCells = <Cell>[];
      for (int row = 0; row < subGridSize; row++) {
        colCells.add(cells[startRow + row][startCol + col]);
      }
      regions.add(Region(
        id: 'subgrid_${subGridIndex}_col_$col',
        type: RegionType.column,
        name: 'SubGrid $subGridIndex Column $col',
        cells: colCells,
      ));
    }

    // 宫区域
    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        final blockCells = <Cell>[];
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            blockCells.add(cells[startRow + blockRow * 3 + i][startCol + blockCol * 3 + j]);
          }
        }
        regions.add(Region(
          id: 'subgrid_${subGridIndex}_block_${blockRow}_$blockCol',
          type: RegionType.block,
          name: 'SubGrid $subGridIndex Block ${blockRow}_$blockCol',
          cells: blockCells,
        ));
      }
    }

    return regions;
  }

  @override
  SamuraiBoard createInstance(
    List<List<Cell>> newCells, {
    List<Region>? regions,
  }) => SamuraiBoard(cells: newCells, regions: regions);

  @override
  int getMaxNumber() => 9;

  @override
  List<Region> createRegions({
    Map<String, dynamic>? templateData,
  }) => _createRegions(cells);

  List<int> getSubGridsForCell(int row, int col) {
    final subGrids = <int>[];
    for (int i = 0; i < 5; i++) {
      final (startRow, startCol) = subGridOffsets[i];
      if (row >= startRow && row < startRow + subGridSize &&
          col >= startCol && col < startCol + subGridSize) {
        subGrids.add(i);
      }
    }
    return subGrids;
  }

  bool isOverlapRegion(int row, int col) => getSubGridsForCell(row, col).length > 1;

  /// 检查单元格是否在可玩区域内（任意子网格中）
  bool isPlayableCell(int row, int col) => getSubGridsForCell(row, col).isNotEmpty;

  /// 获取所有可玩区域内的空单元格
  @override
  List<Cell> getEmptyCells() {
    final emptyCells = <Cell>[];
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (isPlayableCell(row, col)) {
          final cell = cells[row][col];
          if (cell.isEmpty) {
            emptyCells.add(cell);
          }
        }
      }
    }
    return emptyCells;
  }

  /// 获取所有可玩区域内已填单元格
  @override
  List<Cell> getFilledCells() {
    final filledCells = <Cell>[];
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (isPlayableCell(row, col)) {
          final cell = cells[row][col];
          if (!cell.isEmpty) {
            filledCells.add(cell);
          }
        }
      }
    }
    return filledCells;
  }

  /// 检查棋盘是否完整（所有可玩单元格已填）
  @override
  bool isComplete() => getEmptyCells().isEmpty;

  /// 获取可玩单元格总数
  int get playableCellCount {
    int count = 0;
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (isPlayableCell(row, col)) {
          count++;
        }
      }
    }
    return count;
  }

  void mergeSubBoard(Board subBoard, int startRow, int startCol) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        final targetRow = startRow + i;
        final targetCol = startCol + j;
        if (targetRow >= 0 && targetRow < boardSize &&
            targetCol >= 0 && targetCol < boardSize) {
          final subCell = subBoard.getCell(i, j);
          if (subCell.value != null) {
            cells[targetRow][targetCol] = cells[targetRow][targetCol].copyWith(
              value: subCell.value,
              isFixed: true,
            );
          }
        }
      }
    }
  }

  static SamuraiBoard empty() {
    final cells = List.generate(boardSize, (i) => List.generate(boardSize, (j) => Cell(row: i, col: j)));
    return SamuraiBoard(cells: cells);
  }

  @override
  Map<String, dynamic> toJson() => {
    'size': size,
    'cells': cells.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
    'regions': regions.map((region) => region.toJson()).toList(),
  };
}
