// ignore_for_file: use_super_parameters
import 'package:sudoku/core/models/index.dart';

class StandardBoard extends Board {
  StandardBoard({
    required int size,
    required List<List<Cell>> cells,
    List<Region>? regions,
  }) : super(
         size: size,
         cells: cells,
         regions: regions,
       );

  factory StandardBoard.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as int;
    final cellsJson = json['cells'] as List;
    final cells = cellsJson.map((row) {
      final rowList = row as List;
      return rowList
          .map((cellJson) => Cell.fromJson(cellJson as Map<String, dynamic>))
          .toList();
    }).toList();

    final regionsJson = json['regions'] as List?;
    List<Region>? regions;
    if (regionsJson != null && regionsJson.isNotEmpty) {
      regions = regionsJson
          .map(
            (regionJson) => Region.fromJson(regionJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      final tempBoard = StandardBoard(size: size, cells: cells);
      regions = tempBoard.createRegions();
    }

    return StandardBoard(size: size, cells: cells, regions: regions);
  }

  @override
  StandardBoard createInstance(
    List<List<Cell>> newCells, {
    List<Region>? regions,
  }) => StandardBoard(size: size, cells: newCells, regions: regions);

  @override
  List<Region> createRegions({
    Map<String, dynamic>? templateData,
  }) {
    final regions = createDefaultRegions()
    ..addAll(createBlockRegions());
    return regions;
  }

  /// 创建空的标准数独棋盘
  static StandardBoard empty({int size = 9}) {
    final cells = List<List<Cell>>.generate(
      size,
      (i) => List<Cell>.generate(size, (j) => Cell(row: i, col: j)),
    );
    final board = StandardBoard(size: size, cells: cells);
    return StandardBoard(size: size, cells: cells, regions: board.createRegions());
  }
}
