import 'dart:async';
import 'dart:math';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/jigsaw/models/jigsaw_board.dart';

/// 锯齿数独专用生成器（重构版）
class JigsawGenerator implements IGameGenerator {
  JigsawGenerator({Random? random, GameValidator? validator})
    : _random = random ?? Random(),
      _validator = validator ?? GameValidator();
  final Random _random;
  final GameValidator _validator;

  /// 获取JigsawBitSolver实例
  JigsawBitSolver _getSolver(List<List<int>> regionMatrix) =>
      JigsawBitSolver.create(regionMatrix: regionMatrix, random: _random);

  // 难度配置
  static final Map<Difficulty, _JigsawDifficultyConfig> _difficultyConfigs = {
    Difficulty.beginner: _JigsawDifficultyConfig(
      targetFilled: 45,
      minFilled: 40,
      maxFilled: 50,
      maxAttempts: 3,
      timeout: const Duration(seconds: 5),
    ),
    Difficulty.easy: _JigsawDifficultyConfig(
      targetFilled: 38,
      minFilled: 35,
      maxFilled: 42,
      maxAttempts: 3,
      timeout: const Duration(seconds: 8),
    ),
    Difficulty.medium: _JigsawDifficultyConfig(
      targetFilled: 32,
      minFilled: 28,
      maxFilled: 36,
      maxAttempts: 3,
      timeout: const Duration(seconds: 10),
    ),
    Difficulty.hard: _JigsawDifficultyConfig(
      targetFilled: 26,
      minFilled: 22,
      maxFilled: 30,
      maxAttempts: 3,
      timeout: const Duration(seconds: 15),
    ),
    Difficulty.expert: _JigsawDifficultyConfig(
      targetFilled: 22,
      minFilled: 18,
      maxFilled: 26,
      maxAttempts: 3,
      timeout: const Duration(seconds: 20),
    ),
    Difficulty.master: _JigsawDifficultyConfig(
      targetFilled: 18,
      minFilled: 15,
      maxFilled: 22,
      maxAttempts: 3,
      timeout: const Duration(seconds: 30),
    ),
  };

  @override
  GameType get supportedGameType => GameType.jigsaw;

  @override
  Future<GenerationResult> generate({
    required Difficulty difficulty,
    required int size,
    bool Function()? isCancelled,
    Function(GenerationStage)? onStageUpdate,
    Map<String, dynamic>? templateData,
  }) async {
    final stopwatch = Stopwatch()..start();
    final config =
        _difficultyConfigs[difficulty] ??
        _difficultyConfigs[Difficulty.medium]!;

    // 1. 加载区域模板
    onStageUpdate?.call(GenerationStage.loadingTemplate);
    final regionMatrix = await _loadRegionMatrix(
      difficulty,
      config,
      isCancelled,
      templateData,
    );

    // 2. 生成终盘
    onStageUpdate?.call(GenerationStage.generatingSolution);
    final solution = await _generateSolution(
      regionMatrix: regionMatrix,
      config: config,
      isCancelled: isCancelled,
    );

    // 3. 挖空生成谜题
    onStageUpdate?.call(GenerationStage.diggingPuzzle);
    final puzzle = await _generatePuzzle(
      solution: solution,
      config: config,
      isCancelled: isCancelled,
    );

    // 4. 验证谜题与答案匹配
    onStageUpdate?.call(GenerationStage.validating);
    if (!_validator.validatePuzzleSolution(puzzle, solution)) {
      throw GameGenerationNoSolutionException('谜题验证失败');
    }

    stopwatch.stop();

    return GenerationResult(
      solution: solution,
      puzzle: puzzle,
      generationTime: stopwatch.elapsed,
    );
  }

  /// 加载区域模板
  Future<List<List<int>>> _loadRegionMatrix(
    Difficulty difficulty,
    _JigsawDifficultyConfig config,
    bool Function()? isCancelled,
    Map<String, dynamic>? templateData,
  ) async {
    // 首先尝试使用传递的模板数据
    if (templateData != null && templateData.containsKey('regionMatrix')) {
      final regionMatrix = templateData['regionMatrix'] as List<List<int>>;
      // 验证模板有效性（9个连续区域ID 0-8）
      final ids = regionMatrix.expand((row) => row).toSet();
      if (ids.length == 9) {
        for (int i = 0; i < 9; i++) {
          if (!ids.contains(i)) {
            throw GameGenerationException('区域模板无效：缺少区域ID $i');
          }
        }
        return regionMatrix;
      }
    }

    // 当 templateData 为 null 时，抛出明确的错误
    throw GameGenerationException('无法加载区域模板：模板数据未传递');
  }

  /// 生成终盘
  Future<JigsawBoard> _generateSolution({
    required List<List<int>> regionMatrix,
    required _JigsawDifficultyConfig config,
    bool Function()? isCancelled,
  }) async {
    for (int attempt = 0; attempt < config.maxAttempts; attempt++) {
      if (isCancelled?.call() ?? false) {
        throw GameGenerationCancelledException();
      }
      try {
        final solver = _getSolver(regionMatrix);
        final solution = solver.generateSolution(regionMatrix, isCancelled);
        if (solution != null) return solution as JigsawBoard;
      } on TimeoutException {
        // 重试
      }
    }
    throw GameGenerationException('无法生成终盘');
  }

  /// 挖空生成谜题
  Future<JigsawBoard> _generatePuzzle({
    required JigsawBoard solution,
    required _JigsawDifficultyConfig config,
    bool Function()? isCancelled,
  }) async {
    // 关键：先重置 isFixed，否则 setCellValue 无法修改格子
    var puzzle = _resetFixedCells(solution);
    int filled = 81;

    // 收集所有单元格并随机排序
    final cells = [
      for (int r = 0; r < 9; r++)
        for (int c = 0; c < 9; c++) (r, c),
    ]..shuffle(_random);

    for (final (r, c) in cells) {
      if (isCancelled?.call() ?? false) {
        throw GameGenerationCancelledException();
      }
      if (filled <= config.targetFilled) break;

      final testPuzzle = puzzle.setCellValue(r, c, null) as JigsawBoard;
      final unique = await _hasUniqueSolution(testPuzzle);
      if (unique) {
        puzzle = testPuzzle;
        filled--;
      }
    }

    // 若填充数不在目标范围内，尝试调整
    if (filled < config.minFilled || filled > config.maxFilled) {
      puzzle = await _adjustPuzzleDifficulty(
        puzzle: puzzle,
        solution: solution,
        targetFilled: config.targetFilled,
        minFilled: config.minFilled,
        maxFilled: config.maxFilled,
        isCancelled: isCancelled,
      );
    }

    // 设置固定状态（谜题中有值的格子为固定）
    return _setFixedCells(puzzle);
  }

  /// 调整难度（当挖空结果不符合目标范围时）
  Future<JigsawBoard> _adjustPuzzleDifficulty({
    required JigsawBoard puzzle,
    required JigsawBoard solution,
    required int targetFilled,
    required int minFilled,
    required int maxFilled,
    bool Function()? isCancelled,
  }) async {
    var adjusted = puzzle;
    int filled = _countFilled(adjusted);

    // 若填充过多，继续挖空
    while (filled > maxFilled) {
      if (isCancelled?.call() ?? false) break;
      final cells = _findRemovable(adjusted);
      if (cells.isEmpty) break;
      final (r, c) = cells[_random.nextInt(cells.length)];
      final test = adjusted.setCellValue(r, c, null) as JigsawBoard;
      if (await _hasUniqueSolution(test)) {
        adjusted = test;
        filled--;
      } else {
        break;
      }
    }

    // 若填充过少，回填
    while (filled < minFilled) {
      if (isCancelled?.call() ?? false) break;
      final cells = _findFillable(adjusted, solution);
      if (cells.isEmpty) break;
      final (r, c) = cells[_random.nextInt(cells.length)];
      final val = solution.getCell(r, c).value!;
      final test = adjusted.setCellValue(r, c, val) as JigsawBoard;
      if (await _hasUniqueSolution(test)) {
        adjusted = test;
        filled++;
      } else {
        break;
      }
    }

    return adjusted;
  }

  /// 唯一解验证
  Future<bool> _hasUniqueSolution(JigsawBoard puzzle) async {
    final solver = _getSolver(puzzle.regionMatrix!);
    final count = solver.countSolutions(puzzle);
    return count == 1;
  }

  // ========== 辅助函数 ==========

  List<(int, int)> _findRemovable(JigsawBoard puzzle) {
    final list = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (puzzle.getCell(r, c).value != null) list.add((r, c));
      }
    }
    return list;
  }

  List<(int, int)> _findFillable(JigsawBoard puzzle, JigsawBoard solution) {
    final list = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (puzzle.getCell(r, c).value == null) list.add((r, c));
      }
    }
    return list;
  }

  int _countFilled(JigsawBoard board) {
    int cnt = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board.getCell(r, c).value != null) cnt++;
      }
    }
    return cnt;
  }

  JigsawBoard _setFixedCells(JigsawBoard puzzle) {
    final newCells = puzzle.cells
        .map(
          (row) => row
              .map(
                (cell) => Cell(
                  row: cell.row,
                  col: cell.col,
                  value: cell.value,
                  isFixed: cell.value != null,
                ),
              )
              .toList(),
        )
        .toList();
    return puzzle.createInstance(newCells, regions: puzzle.regions);
  }

  /// 重置固定单元格标记（挖空前必须调用）
  JigsawBoard _resetFixedCells(JigsawBoard board) {
    final newCells = board.cells
        .map(
          (row) => row
              .map(
                (cell) => Cell(
                  row: cell.row,
                  col: cell.col,
                  value: cell.value,
                  // isFixed 默认为 false
                ),
              )
              .toList(),
        )
        .toList();
    return board.createInstance(newCells, regions: board.regions);
  }
}

/// 难度配置类
class _JigsawDifficultyConfig {
  _JigsawDifficultyConfig({
    required this.targetFilled,
    required this.minFilled,
    required this.maxFilled,
    required this.maxAttempts,
    required this.timeout,
  });
  final int targetFilled;
  final int minFilled;
  final int maxFilled;
  final int maxAttempts;
  final Duration timeout;
}
