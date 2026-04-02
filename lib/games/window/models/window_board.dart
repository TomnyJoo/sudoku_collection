// ignore_for_file: use_super_parameters
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/window/window_constants.dart';

/// 窗口数独棋盘，在标准数独基础上增加了4个窗口区域（Window）
class WindowBoard extends Board {
  WindowBoard({
    required int size,
    required List<List<Cell>> cells,
    List<Region>? regions,
  }) : super(
         size: size,
         cells: cells,
         regions: regions,
       );

  factory WindowBoard.fromJson(Map<String, dynamic> json) {
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
      regions = regionsJson.map(
            (regionJson) => Region.fromJson(regionJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      final tempBoard = WindowBoard(size: size, cells: cells);
      regions = tempBoard.createRegions();
    }

    return WindowBoard(size: size, cells: cells, regions: regions);
  }

  @override
  WindowBoard createInstance(
    List<List<Cell>> newCells, {
    List<Region>? regions,
  }) => WindowBoard(
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
    
    // 添加窗口区域
    ..addAll(_createWindowRegions());
    
    return regions;
  }

  /// 创建窗口区域
  List<Region> _createWindowRegions() {
    final windows = <Region>[];
    
    // 窗口区域直接使用定义的索引，不需要转换
    for (final windowRegion in WindowConstants.windowRegions) {
      final windowCells = <Cell>[];
      for (int row = windowRegion.startRow; row <= windowRegion.endRow; row++) {
        for (int col = windowRegion.startCol; col <= windowRegion.endCol; col++) {
          windowCells.add(cells[row][col]);
        }
      }
      windows.add(
        Region(
          id: windowRegion.id,
          type: RegionType.window,
          name: windowRegion.name,
          cells: windowCells,
        ),
      );
    }
    
    return windows;
  }

  /// 创建空的窗口数独棋盘
  static WindowBoard empty({int size = 9}) {
    final cells = List<List<Cell>>.generate(
      size,
      (i) => List<Cell>.generate(size, (j) => Cell(row: i, col: j)),
    );
    final board = WindowBoard(size: size, cells: cells);
    return WindowBoard(size: size, cells: cells, regions: board.createRegions());
  }

  @override
  Map<String, dynamic> toJson() => {
    'size': size,
    'cells': cells.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
    'regions': regions.map((region) => region.toJson()).toList(),
  };

  /// 检查指定位置是否在窗口区域内
  bool isInWindowRegion(int row, int col) {
    for (final windowRegion in WindowConstants.windowRegions) {
      if (row >= windowRegion.startRow && row <= windowRegion.endRow &&
          col >= windowRegion.startCol && col <= windowRegion.endCol) {
        return true;
      }
    }
    return false;
  }

  /// 获取指定位置所属的窗口区域ID
  String? getWindowRegionId(int row, int col) {
    for (final windowRegion in WindowConstants.windowRegions) {
      if (row >= windowRegion.startRow && row <= windowRegion.endRow &&
          col >= windowRegion.startCol && col <= windowRegion.endCol) {
        return windowRegion.id;
      }
    }
    return null;
  }
}
