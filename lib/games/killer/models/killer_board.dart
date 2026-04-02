// ignore_for_file: use_super_parameters

import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/games/killer/models/killer_cage.dart';

class KillerBoard extends Board {

  KillerBoard({
    required int size,
    required List<List<Cell>> cells,
    List<Region>? regions,
    List<KillerCage>? cages,
  }) : cages = cages ?? [],
       super(
         size: size,
         cells: cells,
         regions: regions,
       );

  factory KillerBoard.fromJson(Map<String, dynamic> json) {
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
    }

    final cagesJson = json['cages'] as List?;
    final cages = cagesJson
        ?.map(
          (cageJson) => KillerCage.fromJson(cageJson as Map<String, dynamic>),
        )
        .toList() ?? [];

    final board = KillerBoard(size: size, cells: cells, regions: regions, cages: cages);
    // 如果没有区域信息，生成区域
    if (regions == null || regions.isEmpty) {
      final generatedRegions = board.createRegions();
      return KillerBoard(size: size, cells: cells, regions: generatedRegions, cages: cages);
    }

    return board;
  }
  final List<KillerCage> cages;
  
  // ⭐ Cage查找缓存 - 提升性能
  Map<String, KillerCage>? _cageLookupCache;
  int? _cageLookupCacheHash;

  @override
  KillerBoard createInstance(
    List<List<Cell>> newCells, {
    List<Region>? regions,
  }) => KillerBoard(
      size: size,
      cells: newCells,
      regions: regions,
      cages: cages,
    );

  @override
  List<Region> createRegions({
    Map<String, dynamic>? templateData,
  }) {
    final regions = createDefaultRegions()
    ..addAll(createBlockRegions());
    
    // 添加笼子区域
    for (final cage in cages) {
      final cageCells = <Cell>[];
      for (final (row, col) in cage.cellCoordinates) {
        if (row >= 0 && row < size && col >= 0 && col < size) {
          cageCells.add(cells[row][col]);
        }
      }
      if (cageCells.isNotEmpty) {
        regions.add(Region(
          id: 'cage_${cage.id}',
          type: RegionType.cage,
          name: 'Cage ${cage.sum}',
          cells: cageCells,
        ));
      }
    }
    
    return regions;
  }

  static KillerBoard empty({int size = 9}) {
    final cells = List<List<Cell>>.generate(
      size,
      (i) => List<Cell>.generate(size, (j) => Cell(row: i, col: j)),
    );
    final board = KillerBoard(size: size, cells: cells);
    return KillerBoard(size: size, cells: cells, regions: board.createRegions());
  }

  @override
  Map<String, dynamic> toJson() => {
    'size': size,
    'cells': cells.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
    'regions': regions.map((region) => region.toJson()).toList(),
    'cages': cages.map((cage) => cage.toJson()).toList(),
  };

  KillerCage? getCageForCell(int row, int col) {
    // ⭐ 使用缓存优化
    final cacheKey = '$row,$col';
    
    // 检查缓存是否需要重建
    final currentHash = Object.hashAll(cages.map((c) => c.id));
    if (_cageLookupCache == null || _cageLookupCacheHash != currentHash) {
      _buildCageLookupCache();
      _cageLookupCacheHash = currentHash;
    }
    
    return _cageLookupCache?[cacheKey];
  }
  
  /// 构建cage查找缓存
  void _buildCageLookupCache() {
    _cageLookupCache = <String, KillerCage>{};
    for (final cage in cages) {
      for (final coord in cage.cellCoordinates) {
        final key = '${coord.$1},${coord.$2}';
        _cageLookupCache![key] = cage;
      }
    }
  }

  /// 获取棋盘状态哈希值，用于缓存优化
  /// 
  /// 基于所有单元格的值计算哈希，当棋盘状态改变时哈希值会变化
  int get stateHash {
    var hash = 0;
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        final cell = cells[i][j];
        // 包含单元格值
        if (cell.value != null) {
          hash = hash * 31 + cell.value! + i * 9 + j;
        }
        // 包含选择状态
        if (cell.isSelected) {
          hash = hash * 31 + 1000 + i * 9 + j;
        }
        // 包含高亮状态
        if (cell.isHighlighted) {
          hash = hash * 31 + 2000 + i * 9 + j;
        }
        // 包含固定状态
        if (cell.isFixed) {
          hash = hash * 31 + 3000 + i * 9 + j;
        }
        // 包含错误状态
        if (cell.isError) {
          hash = hash * 31 + 4000 + i * 9 + j;
        }
        // 包含候选数
        for (final candidate in cell.candidates) {
          hash = hash * 31 + 5000 + candidate + i * 9 + j;
        }
      }
    }
    return hash;
  }

  /// 获取所有笼子的验证状态
  Map<String, bool> getCagesValidationStatus() {
    final result = <String, bool>{};
    for (final cage in cages) {
      result[cage.id] = cage.isValid(this);
    }
    return result;
  }

  /// 检查所有笼子是否都有效
  bool get areAllCagesValid {
    for (final cage in cages) {
      if (!cage.isValid(this)) return false;
    }
    return true;
  }

  /// 重写选择指定单元格，修改高亮逻辑，删除后半条规则
  @override
  Board selectCell(final int row, final int col) {
    final newCells = cells
        .map(
          (final r) => r
              .map(
                (final c) => c.copyWith(
                  isSelected: c.row == row && c.col == col,
                  isHighlighted: false,
                ),
              )
              .toList(),
        )
        .toList();

    final selectedCell = newCells[row][col];
    final finalCells = newCells
        .map(
          (final r) => r
              .map(
                (final c) {
                  bool isHighlighted = false;
                  if (selectedCell.value != null) {
                    isHighlighted = c.value != null &&
                        c.value == selectedCell.value &&
                        c.row != row &&
                        c.col != col;
                  }
                  return c.copyWith(isHighlighted: isHighlighted);
                },
              )
              .toList(),
        )
        .toList();

    final newRegions = regions.map((region) {
      final newRegionCells = region.cells
          .map((c) => finalCells[c.row][c.col])
          .toList();
      return Region(
        id: region.id,
        type: region.type,
        name: region.name,
        cells: newRegionCells,
      );
    }).toList();

    return createInstance(finalCells, regions: newRegions);
  }
}
