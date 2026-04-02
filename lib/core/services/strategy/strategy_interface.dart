import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/services/candidate_calculator.dart';

/// 策略接口
abstract class Strategy {
  const Strategy();
  
  StrategyType get type;
  StrategyLevel get level;
  Set<GameType> get applicableGames;
  
  bool apply(BoardContext context);
}



/// 策略执行器
class StrategyExecutor {
  static bool execute(
    BoardContext context,
    List<Strategy> strategies
  ) {
    const int maxIterations = 50; // 防止无限循环
    int iteration = 0;
    
    // 使用 while 循环，每次遍历所有策略一次
    while (iteration < maxIterations) {
      bool applied = false;
      for (final strategy in strategies) {
        if (strategy.apply(context)) {
          // 每次策略应用后，验证候选数是否有效
          final validationResult = _validateCandidates(context);
          if (!validationResult.isValid) {
            // 打印策略名称和问题信息，帮助定位问题
            AppLogger.warning(
              '策略 ${strategy.type.name} 产生了无效候选数: ${validationResult.reason}'
            );
            // 发现矛盾，立即返回 false
            return false;
          }
          
          applied = true;
        }
      }
      if (!applied) break;
      iteration++;
    }
    // 执行完成，没有发现矛盾
    return true;
  }
  
  /// 验证结果
  static const _ValidationResult _validResult = _ValidationResult(isValid: true, reason: '');
  
  /// 验证候选数是否有效
  /// 1. 空单元格的候选数不能为空
  /// 2. 已填单元格的候选数应该为空
  /// 3. 候选数不能与已填数字冲突
  /// 4. 候选数必须是1-9之间的数字
  /// 5. 同一区域不能出现相同的裸单
  /// 6. 同一区域不能出现重复的已填数字
  /// 7. 裸单不能与已填数字冲突
  static _ValidationResult _validateCandidates(BoardContext context) {
    final n = context.size;
    
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final cell = context.board.getCell(r, c);
        final candidates = context.getCandidates(r, c);
        
        // 检查1：空单元格的候选数不能为空
        if (cell.value == null) {
          if (candidates.isEmpty) {
            return _ValidationResult(
              isValid: false,
              reason: '单元格 ($r, $c) 候选数为空',
            );
          }
        } else {
          // 检查2：已填单元格的候选数应该为空
          if (candidates.isNotEmpty) {
            return _ValidationResult(
              isValid: false,
              reason: '单元格 ($r, $c) 已填值 ${cell.value}，但候选数不为空',
            );
          }
        }
        
        // 检查3：候选数必须是1-maxNumber之间的数字
        final maxNumber = context.board.getMaxNumber();
        for (final num in candidates) {
          if (num < 1 || num > maxNumber) {
            return _ValidationResult(
              isValid: false,
              reason: '单元格 ($r, $c) 候选数包含无效数字 $num，必须在1-$maxNumber之间',
            );
          }
        }
        
        // 检查4：候选数不能与已填数字冲突
        // 检查所有相关区域
        for (final regIdx in context.cellToRegions[r][c]) {
          final cells = context.getRegionCells(regIdx);
          for (final idx in cells) {
            final cr = idx ~/ n;
            final cc = idx % n;
            if (cr == r && cc == c) continue;
            final otherCell = context.board.getCell(cr, cc);
            if (otherCell.value != null && context.hasCandidate(r, c, otherCell.value!)) {
              final regionType = context.getRegionType(regIdx);
              return _ValidationResult(
                isValid: false,
                reason: '单元格 ($r, $c) 候选数包含${regionType.name}已填数字 ${otherCell.value}',
              );
            }
          }
        }
      }
    }
    
    // 检查5：同一区域不能出现重复的已填数字
    for (int regIdx = 0; regIdx < context.regionCellIndices.length; regIdx++) {
      final cells = context.getRegionCells(regIdx);
      final region = context.getRegion(regIdx);
      if (region.cells.length != context.board.getMaxNumber()) continue; // 只检查标准大小的区域
      
      final seenValues = <int>{};
      for (final idx in cells) {
        final r = idx ~/ n;
        final c = idx % n;
        final cell = context.board.getCell(r, c);
        if (cell.value != null) {
          if (seenValues.contains(cell.value)) {
            final regionType = context.getRegionType(regIdx);
            return _ValidationResult(
              isValid: false,
              reason: '区域 $regIdx (${regionType.name}) 中出现重复的已填数字 ${cell.value}',
            );
          }
          seenValues.add(cell.value!);
        }
      }
    }
    
    // 检查6：同一区域不能出现相同的裸单
    for (int regIdx = 0; regIdx < context.regionCellIndices.length; regIdx++) {
      final cells = context.getRegionCells(regIdx);
      final region = context.getRegion(regIdx);
      if (region.cells.length != context.board.getMaxNumber()) continue; // 只检查标准大小的区域
      
      final nakedSingles = <(int, int, int)>[];
      for (final idx in cells) {
        final r = idx ~/ n;
        final c = idx % n;
        final candidates = context.getCandidates(r, c).toSet();
        if (candidates.length == 1 && context.board.getCell(r, c).value == null) {
          final num = candidates.first;
          nakedSingles.add((r, c, num));
        }
      }
      
      // 检查是否有重复的裸单
      final seen = <int, (int, int)>{}; // 数字 -> (行, 列)
      for (final (r, c, num) in nakedSingles) {
        // 检查7：裸单不能与已填数字冲突
        for (final idx in cells) {
          final cr = idx ~/ n;
          final cc = idx % n;
          if (cr == r && cc == c) continue;
          final cell = context.board.getCell(cr, cc);
          if (cell.value == num) {
            final regionType = context.getRegionType(regIdx);
            return _ValidationResult(
              isValid: false,
              reason: '区域 $regIdx (${regionType.name}) 中裸单数字 $num 与已填数字冲突',
            );
          }
        }
        
        if (seen.containsKey(num)) {
          final (otherR, otherC) = seen[num]!;
          return _ValidationResult(
            isValid: false,
            reason: '区域 $regIdx 中出现重复的裸单数字 $num 在 ($r, $c) 和 ($otherR, $otherC)',
          );
        }
        seen[num] = (r, c);
      }
    }
    
    return _validResult;
  }
}

/// 策略验证异常
class StrategyValidationException implements Exception {
  const StrategyValidationException(this.message);
  
  final String message;
  
  @override
  String toString() => 'StrategyValidationException: $message';
}

/// 验证结果类
class _ValidationResult {
  const _ValidationResult({required this.isValid, required this.reason});
  
  final bool isValid;
  final String reason;
}
