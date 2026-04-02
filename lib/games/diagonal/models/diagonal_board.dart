// ignore_for_file: use_super_parameters
import 'package:sudoku/core/models/index.dart';

class DiagonalBoard extends Board {
  DiagonalBoard({
    required int size,
    required List<List<Cell>> cells,
    List<Region>? regions,
  }) : super(
         size: size,
         cells: cells,
         regions: regions,
       );

  factory DiagonalBoard.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as int;
    final cellsJson = json['cells'] as List;
    final cells = cellsJson.map((row) {
      final rowList = row as List;
      return rowList
          .map((cellJson) => Cell.fromJson(cellJson as Map<String, dynamic>))
          .toList();
    }).toList();

    final regionsJson = json['regions'] as List?;
    final regions = regionsJson
        ?.map(
          (regionJson) => Region.fromJson(regionJson as Map<String, dynamic>),
        )
        .toList();

    final board = DiagonalBoard(size: size, cells: cells, regions: regions);
    // 如果没有区域信息，生成区域
    if (regions == null || regions.isEmpty) {
      final generatedRegions = board.createRegions();
      return DiagonalBoard(size: size, cells: cells, regions: generatedRegions);
    }

    return board;
  }

  @override
  DiagonalBoard createInstance(
    List<List<Cell>> newCells, {
    List<Region>? regions,
  }) => DiagonalBoard(
      size: size,
      cells: newCells,
      regions: regions,
    );

  @override
  List<Region> createRegions({
    Map<String, dynamic>? templateData,
  }) {
    final regions = createDefaultRegions()
    ..addAll(createBlockRegions())
    
    // 添加对角线区域
    ..add(_createMainDiagonalRegion())
    ..add(_createAntiDiagonalRegion());
    
    return regions;
  }

  /// 创建主对角线区域
  Region _createMainDiagonalRegion() {
    final diagonalCells = <Cell>[];
    for (int i = 0; i < size; i++) {
      diagonalCells.add(cells[i][i]);
    }
    return Region(
      id: 'diagonal_main',
      type: RegionType.diagonal,
      name: 'Main Diagonal',
      cells: diagonalCells,
    );
  }

  /// 创建反对角线区域
  Region _createAntiDiagonalRegion() {
    final diagonalCells = <Cell>[];
    for (int i = 0; i < size; i++) {
      diagonalCells.add(cells[i][size - 1 - i]);
    }
    return Region(
      id: 'diagonal_anti',
      type: RegionType.diagonal,
      name: 'Anti Diagonal',
      cells: diagonalCells,
    );
  }

  /// 创建空的对角线数独棋盘
  static DiagonalBoard empty({int size = 9}) {
    final cells = List<List<Cell>>.generate(
      size,
      (i) => List<Cell>.generate(size, (j) => Cell(row: i, col: j)),
    );
    final board = DiagonalBoard(size: size, cells: cells);
    // 生成区域
    final regions = board.createRegions();
    return DiagonalBoard(size: size, cells: cells, regions: regions);
  }
}
