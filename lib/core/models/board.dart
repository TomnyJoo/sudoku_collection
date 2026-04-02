import 'dart:math';
import 'package:sudoku/core/models/cell.dart';
import 'package:sudoku/core/models/region.dart';

/// 数独棋盘抽象基类，封装棋盘状态和操作，提供统一的接口，支持不同类型的数独游戏（标准、锯齿、对角线等）
abstract class Board {
  /// 构造棋盘模型
  Board({required this.size, required this.cells, final List<Region>? regions})
    : regions = regions ?? [] {
    // 验证棋盘尺寸
    if (size <= 0) {
      final errorMsg = '棋盘尺寸必须大于0: $size';
      throw ArgumentError(errorMsg);
    }

    // 验证单元格矩阵
    if (cells.length != size) {
      final errorMsg = '棋盘行数必须等于尺寸: ${cells.length} != $size';
      throw ArgumentError(errorMsg);
    }

    for (var i = 0; i < cells.length; i++) {
      if (cells[i].length != size) {
        final errorMsg = '第$i行列数必须等于尺寸: ${cells[i].length} != $size';
        throw ArgumentError(errorMsg);
      }

      for (var j = 0; j < cells[i].length; j++) {
        final cell = cells[i][j];
        if (cell.row != i || cell.col != j) {
          final errorMsg = '单元格坐标不匹配: ($i,$j) != (${cell.row},${cell.col})';
          throw ArgumentError(errorMsg);
        }
      }
    }
  }

  /// 从JSON创建棋盘实例（需要子类实现）
  /// 
  /// 这是一个静态辅助方法，子类应该提供自己的fromJson实现
  /// 例如：StandardBoard.fromJson(Map< String, dynamic> json)
  static Board fromJson(Map<String, dynamic> json) {
    throw UnsupportedError(
      'Board.fromJson() must be implemented by subclasses',
    );
  }

  final int size;

  /// 棋盘尺寸（通常为9）
  final List<List<Cell>> cells;

  /// 棋盘单元格矩阵（行优先）
  final List<Region> regions;

  /// 区域集合（用于区域验证）

  /// 获取指定位置的单元格
  Cell getCell(final int row, final int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      final errorMsg = '坐标超出范围: row=$row, col=$col, size=$size';
      throw RangeError(errorMsg);
    }
    return cells[row][col];
  }


  /// 设置单元格值
  Board setCellValue(final int row, final int col, final int? value) {
    final cell = getCell(row, col);
    if (!cell.isEditable) return this;

    final newCell = cell.setValue(value);
    return _updateCell(row, col, newCell);
  }

  /// 设置整个单元格（包括固定状态）
  Board setCell(final int row, final int col, final Cell newCell) =>
      _updateCell(row, col, newCell);

  /// 设置单元格候选数字
  Board setCellCandidates(
    final int row,
    final int col,
    final Set<int> candidates,
  ) {
    final cell = getCell(row, col);
    final newCell = cell.copyWith(candidates: candidates);
    return _updateCell(row, col, newCell);
  }

  /// 添加单元格候选数字
  Board addCellCandidate(final int row, final int col, final int number) {
    final cell = getCell(row, col);
    final newCell = cell.addCandidate(number);
    return _updateCell(row, col, newCell);
  }

  /// 移除单元格候选数字
  Board removeCellCandidate(final int row, final int col, final int number) {
    final cell = getCell(row, col);
    final newCell = cell.removeCandidate(number);
    return _updateCell(row, col, newCell);
  }

  /// 切换单元格候选数字
  Board toggleCellCandidate(final int row, final int col, final int number) {
    final cell = getCell(row, col);
    final newCell = cell.toggleCandidate(number);
    return _updateCell(row, col, newCell);
  }

  /// 清除单元格内容（保留固定状态）
  Board clearCell(final int row, final int col) {
    final cell = getCell(row, col);
    if (!cell.isEditable) return this;

    final newCell = cell.clear();
    return _updateCell(row, col, newCell);
  }

  /// 选择单元格
  Board selectCell(final int row, final int col) {
    // 先清除所有选择状态
    final clearedBoard = _clearAllSelection();

    // 设置新选择状态
    final cell = clearedBoard.getCell(row, col);
    final newCell = cell.copyWith(isSelected: true);

    // 设置高亮状态
    final highlightedBoard = clearedBoard._updateCell(row, col, newCell);
    return highlightedBoard._updateHighlights(row, col);
  }

  /// 清除所有选择状态
  Board clearSelection() => _clearAllSelection();

  /// 设置单元格错误状态
  Board setCellError(final int row, final int col, final bool isError) {
    final cell = getCell(row, col);
    final newCell = cell.copyWith(isError: isError);
    return _updateCell(row, col, newCell);
  }

  /// 获取指定行的所有单元格
  List<Cell> getRow(final int row) => List<Cell>.from(cells[row]);

  /// 获取指定列的所有单元格
  List<Cell> getColumn(final int col) =>
      List<Cell>.generate(size, (final i) => cells[i][col]);

  /// 获取指定区域的所有单元格
  List<Cell> getRegion(final String regionId) {
    final region = regions.firstWhere(
      (final r) => r.id == regionId,
      orElse: () => throw ArgumentError('区域不存在: $regionId'),
    );

    return List<Cell>.from(region.cells);
  }

  /// 获取所有空单元格
  List<Cell> getEmptyCells() {
    final emptyCells = <Cell>[];
    for (final row in cells) {
      for (final cell in row) {
        if (cell.isEmpty) {
          emptyCells.add(cell);
        }
      }
    }
    return emptyCells;
  }

  /// 获取所有已填单元格
  List<Cell> getFilledCells() {
    final filledCells = <Cell>[];
    for (final row in cells) {
      for (final cell in row) {
        if (!cell.isEmpty) {
          filledCells.add(cell);
        }
      }
    }
    return filledCells;
  }

  /// 检查棋盘是否完整（所有单元格已填）
  bool isComplete() => getEmptyCells().isEmpty;

  /// 计算数字使用次数统计，返回数字使用次数的映射
  Map<int, int> calculateNumberCounts() {
    final counts = <int, int>{};
    for (var i = 1; i <= size; i++) {
      // 改进：使用size而不是固定9
      counts[i] = 0;
    }

    for (final row in cells) {
      for (final cell in row) {
        if (cell.value != null) {
          counts[cell.value!] = (counts[cell.value!] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  /// 清空棋盘（保留固定数字）
  Board reset() {
    final newCells = cells
        .map(
          (final row) => row
              .map((final cell) => cell.isFixed ? cell : cell.clear())
              .toList(),
        )
        .toList();

    final newRegions = regions.map((region) {
      final newRegionCells = region.cells
          .map((cell) => newCells[cell.row][cell.col])
          .toList();
      return Region(
        id: region.id,
        type: region.type,
        name: region.name,
        cells: newRegionCells,
      );
    }).toList();

    return createInstance(newCells, regions: newRegions);
  }

  // region 私有方法

  /// 更新单元格
  Board _updateCell(final int row, final int col, final Cell newCell) {
    final newCells = cells.map(List<Cell>.from).toList();
    newCells[row][col] = newCell;

    // 同步更新 regions 中的 cells
    final newRegions = regions.map((region) {
      final newRegionCells = region.cells.map((cell) {
        if (cell.row == row && cell.col == col) {
          return newCell;
        }
        return cell;
      }).toList();
      return Region(
        id: region.id,
        type: region.type,
        name: region.name,
        cells: newRegionCells,
      );
    }).toList();

    return createInstance(newCells, regions: newRegions);
  }

  /// 清除所有选择状态
  Board _clearAllSelection() {
    final newCells = cells
        .map(
          (final row) => row
              .map(
                (final cell) =>
                    cell.copyWith(isSelected: false, isHighlighted: false),
              )
              .toList(),
        )
        .toList();

    final newRegions = regions.map((region) {
      final newRegionCells = region.cells
          .map((cell) => newCells[cell.row][cell.col])
          .toList();
      return Region(
        id: region.id,
        type: region.type,
        name: region.name,
        cells: newRegionCells,
      );
    }).toList();

    return createInstance(newCells, regions: newRegions);
  }

  /// 更新高亮状态
  Board _updateHighlights(final int selectedRow, final int selectedCol) {
    final newCells = cells
        .map(
          (final row) => row
              .map(
                (final cell) => cell.copyWith(
                  isHighlighted: _shouldHighlightCell(
                    cell,
                    selectedRow,
                    selectedCol,
                  ),
                ),
              )
              .toList(),
        )
        .toList();

    final newRegions = regions.map((region) {
      final newRegionCells = region.cells
          .map((cell) => newCells[cell.row][cell.col])
          .toList();
      return Region(
        id: region.id,
        type: region.type,
        name: region.name,
        cells: newRegionCells,
      );
    }).toList();

    return createInstance(newCells, regions: newRegions);
  }

  /// 检查单元格是否应该高亮
  bool _shouldHighlightCell(
    final Cell cell,
    final int selectedRow,
    final int selectedCol,
  ) {
    final selectedCell = getCell(selectedRow, selectedCol);

    // 如果选中的单元格有值，则高亮相同值的单元格
    if (selectedCell.value != null) {
      return cell.value != null &&
          cell.value == selectedCell.value &&
          cell.row != selectedRow &&
          cell.col != selectedCol;
    } else {
      // 如果选中的单元格无值，则高亮相同行、同列或同区域的单元格
      // 同行或同列
      if (cell.row == selectedRow || cell.col == selectedCol) {
        return true;
      }

      // 同区域（如果区域集合存在）
      if (regions.isNotEmpty) {
        // 查找包含选中单元格的区域
        final selectedCellRegions = regions
            .where(
              (region) => region.containsCoordinate(selectedRow, selectedCol),
            )
            .toList();

        // 查找包含当前单元格的区域
        final currentCellRegions = regions
            .where((region) => region.containsCoordinate(cell.row, cell.col))
            .toList();

        // 检查是否有共同的区域
        for (final selectedRegion in selectedCellRegions) {
          for (final currentRegion in currentCellRegions) {
            if (selectedRegion.id == currentRegion.id) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  // endregion

  /// 获取用于调试的字符串表示（不依赖国际化）
  String toDebugString() {
    final filledCells = getFilledCells().length;
    final totalCells = size * size;
    final completionPercent = (filledCells / totalCells * 100).toStringAsFixed(
      1,
    );

    return 'Board(size: $size, cells: $filledCells/$totalCells ($completionPercent%完成))';
  }

  /// 将棋盘转换为JSON格式
  Map<String, dynamic> toJson() => {
    'size': size,
    'cells': cells
        .map((row) => row.map((cell) => cell.toJson()).toList())
        .toList(),
    'regions': regions.map((region) => region.toJson()).toList(),
  };

  /// 创建棋盘的副本，支持选择性更新
  Board copyWith({final List<List<Cell>>? cells, final List<Region>? regions}) {
    // 创建cells的深拷贝，避免引用问题
    final cellsCopy =
        cells ??
        this.cells
            .map((row) => row.map((cell) => cell.copyWith()).toList())
            .toList();
    return createInstance(cellsCopy, regions: regions ?? this.regions);
  }

  /// 创建新棋盘实例（子类需要实现）
  Board createInstance(
    final List<List<Cell>> newCells, {
    final List<Region>? regions,
  }) => throw UnsupportedError(
    'createInstance() must be implemented by subclasses',
  );

  /// 创建空棋盘的便捷方法 - 抽象方法，需由子类实现
  /// 
  /// 子类应该提供自己的empty实现
  /// 例如：static StandardBoard empty({int size = 9})
  static Board empty({int size = 9}) {
    throw UnsupportedError('Board.empty() must be implemented by subclasses');
  }

  /// 创建所有区域（包括通用区域和特殊区域）
  /// 子类必须实现此方法，确保区域创建的统一性
  List<Region> createRegions({
    Map<String, dynamic>? templateData,
  }) => createDefaultRegions(); // 默认实现：创建通用区域（行、列）

  /// 创建默认的行和列区域
  ///
  /// 此方法为所有数独类型生成标准的行和列区域，
  /// 避免子类重复实现相同的逻辑。
  ///
  /// Returns:
  ///   包含所有行和列区域的列表
  List<Region> createDefaultRegions() {
    final regions = <Region>[];

    // 添加行区域
    for (int i = 0; i < size; i++) {
      final rowCells = List<Cell>.generate(size, (j) => cells[i][j]);
      regions.add(
        Region(
          id: 'row_$i',
          type: RegionType.row,
          name: 'Row $i',
          cells: rowCells,
        ),
      );
    }

    // 添加列区域
    for (int j = 0; j < size; j++) {
      final colCells = List<Cell>.generate(size, (i) => cells[i][j]);
      regions.add(
        Region(
          id: 'col_$j',
          type: RegionType.column,
          name: 'Column $j',
          cells: colCells,
        ),
      );
    }

    return regions;
  }

  /// 创建宫格区域
  /// 
  /// [blockSize] - 宫格大小，默认为自动计算（sqrt(size)）
  /// [regionType] - 区域类型，默认为 RegionType.block
  /// [regionPrefix] - 区域ID前缀，默认为 'block'
  List<Region> createBlockRegions({
    int? blockSize,
    RegionType regionType = RegionType.block,
    String regionPrefix = 'block',
  }) {
    final actualBlockSize = blockSize ?? sqrt(size).toInt();
    final regions = <Region>[];
    
    for (int blockRow = 0; blockRow < actualBlockSize; blockRow++) {
      for (int blockCol = 0; blockCol < actualBlockSize; blockCol++) {
        final blockCells = <Cell>[];
        for (int i = 0; i < actualBlockSize; i++) {
          for (int j = 0; j < actualBlockSize; j++) {
            final row = (blockRow * actualBlockSize + i).toInt();
            final col = (blockCol * actualBlockSize + j).toInt();
            if (row < size && col < size) {
              blockCells.add(cells[row][col]);
            }
          }
        }
        if (blockCells.isNotEmpty) {
          regions.add(
            Region(
              id: '${regionPrefix}_${blockRow}_$blockCol',
              type: regionType,
              name: '${regionPrefix[0].toUpperCase()}${regionPrefix.substring(1)} ${blockRow}_$blockCol',
              cells: blockCells,
            ),
          );
        }
      }
    }
    
    return regions;
  }

  /// 获取数独游戏中使用的最大数字
  /// 默认为size，适用于标准数独、对角线数独、窗口数独等
  /// 武士数独需要重写此方法返回9
  int getMaxNumber() => size;
}
