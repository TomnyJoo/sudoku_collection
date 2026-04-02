/// 杀手数独组合检查工具类（优化版）
class KillerCombinationChecker {
  // 缓存笼子的所有可能组合（不包含候选数掩码）
  static final Map<String, List<List<int>>> _cageComboCache = {};

  /// 应用笼子约束到候选数
  static bool applyCageConstraint(
    int sum,
    List<(int, int)> cells,
    Set<int> Function(int, int) getCandidates,
    void Function(int, int, Set<int>) setCandidates,
    int? Function(int, int) getCellValue,
  ) {
    // 检查并清理缓存
    if (_cageComboCache.length > 5000) _cageComboCache.clear();
    
    final n = cells.length;
    final filled = <int>{};
    int filledSum = 0;
    final emptyIndices = <int>[];
    final emptyCandidates = <Set<int>>[];

    for (int i = 0; i < n; i++) {
      final (r, c) = cells[i];
      final val = getCellValue(r, c);
      if (val != null) {
        filled.add(val);
        filledSum += val;
      } else {
        emptyIndices.add(i);
        emptyCandidates.add(getCandidates(r, c));
      }
    }

    final remainingSum = sum - filledSum;
    // 修复：当remainingSum < 0时，说明已有数字之和超过笼子总和
    // 不应该清空候选数，而是返回false表示无法应用约束
    if (remainingSum < 0) {
      return false;
    }
    if (emptyIndices.isEmpty) return false;

    // 限制空单元格数量，避免组合爆炸
    const maxCells = 5;
    if (emptyIndices.length > maxCells) {
      // 当空单元格太多时，至少要应用基本约束
      _applyBasicConstraints(cells, emptyIndices, remainingSum, getCandidates, setCandidates);
      return true;
    }

    // 生成缓存键（不包含候选数，只包含笼子的静态信息）
    final cacheKey = _makeCageCacheKey(sum, n, filled, emptyIndices.length);
    
    // 获取所有可能的组合（从缓存或重新计算）
    List<List<int>>? allCombos = _cageComboCache[cacheKey];
    if (allCombos == null) {
      allCombos = [];
      _enumerateAllCombinations(
        emptyIndices.length,
        remainingSum,
        filled,
        allCombos,
      );
      _cageComboCache[cacheKey] = allCombos;
    }
    
    // 如果没有可能的组合，返回false
    if (allCombos.isEmpty) {
      return false;
    }
    
    // 根据当前候选数过滤组合
    final filteredCombos = <List<int>>[];
    for (final combo in allCombos) {
      bool isValid = true;
      for (int i = 0; i < combo.length; i++) {
        final candidates = emptyCandidates[i];
        if (!candidates.contains(combo[i])) {
          isValid = false;
          break;
        }
      }
      if (isValid) {
        filteredCombos.add(combo);
      }
    }
    
    // 如果过滤后没有组合，返回false
    if (filteredCombos.isEmpty) {
      return false;
    }

    final newCandidatesList = List<Set<int>>.generate(
      emptyIndices.length,
      (_) => <int>{},
    );
    for (final combo in filteredCombos) {
      for (int i = 0; i < combo.length; i++) {
        newCandidatesList[i].add(combo[i]);
      }
    }

    bool anyChanged = false;
    for (int i = 0; i < emptyIndices.length; i++) {
      final (r, c) = cells[emptyIndices[i]];
      final oldCandidates = getCandidates(r, c);
      final newCandidates = newCandidatesList[i];
      if (newCandidates.isNotEmpty && newCandidates != oldCandidates) {
        setCandidates(r, c, newCandidates);
        anyChanged = true;
      }
    }
    return anyChanged;
  }

  /// 应用基本约束（当空单元格太多时使用）
  static void _applyBasicConstraints(
    List<(int, int)> cells,
    List<int> emptyIndices,
    int remainingSum,
    Set<int> Function(int, int) getCandidates,
    void Function(int, int, Set<int>) setCandidates,
  ) {
    final emptyCount = emptyIndices.length;
    
    for (final i in emptyIndices) {
      final (r, c) = cells[i];
      final candidates = getCandidates(r, c);
      final validCandidates = <int>{};
      
      for (final digit in candidates) {
        // 检查该数字是否可能是某个有效组合的一部分
        final remainingAfterDigit = remainingSum - digit;
        final remainingEmpty = emptyCount - 1;
        
        if (remainingEmpty == 0) {
          if (remainingAfterDigit == 0) {
            validCandidates.add(digit);
          }
        } else {
          final minRemain = remainingEmpty * (remainingEmpty + 1) ~/ 2;
          final maxRemain = 9 * remainingEmpty - (remainingEmpty * (remainingEmpty - 1) ~/ 2);
          if (remainingAfterDigit >= minRemain && remainingAfterDigit <= maxRemain) {
            validCandidates.add(digit);
          }
        }
      }
      
      if (validCandidates.isNotEmpty && validCandidates != candidates) {
        setCandidates(r, c, validCandidates);
      }
    }
  }

  /// 生成笼子缓存键（不包含候选数掩码，只包含笼子的静态信息）
  static String _makeCageCacheKey(
    int sum,
    int n,
    Set<int> filled,
    int emptyCount,
  ) {
    final sb = StringBuffer()
      ..write('sum:$sum;')
      ..write('n:$n;');
    final sortedFilled = filled.toList()..sort();
    sb
      ..write('filled:${sortedFilled.join(',')}')
      ..write('empty:$emptyCount');
    return sb.toString();
  }

  /// 枚举所有可能的排列（用于缓存）
  static void _enumerateAllCombinations(
    int k,
    int targetSum,
    Set<int> used,
    List<List<int>> result,
  ) {
    _enumeratePermutationsHelper(k, targetSum, used, result, <int>[]);
  }
  
  /// 辅助方法：枚举所有可能的排列
  static void _enumeratePermutationsHelper(
    int k,
    int targetSum,
    Set<int> used,
    List<List<int>> result,
    List<int> current,
  ) {
    if (k == 0) {
      if (targetSum == 0) result.add(List.from(current));
      return;
    }
    for (int num = 1; num <= 9; num++) {
      if (used.contains(num)) continue;
      if (num > targetSum) continue;
      current.add(num);
      final newUsed = Set<int>.from(used)..add(num);
      _enumeratePermutationsHelper(
        k - 1,
        targetSum - num,
        newUsed,
        result,
        current,
      );
      current.removeLast();
    }
  }

  /// 检查是否存在满足条件的组合（供外部调用）
  static bool existsCombination(
    int positions,
    int targetSum,
    Set<int> filled,
    List<Set<int>> emptyCandidates,
    int mustIncludeDigit,
  ) {
    final used = filled.toSet();
    return _dfs(
      positions,
      targetSum,
      used,
      emptyCandidates,
      mustIncludeDigit,
      0,
      mustIncludeDigit == -1, // 如果不强制包含任何数字，初始included为true
    );
  }

  /// 深度优先搜索，查找满足条件的组合
  static bool _dfs(
    int positions,
    int remainingSum,
    Set<int> used,
    List<Set<int>> emptyCandidates,
    int mustIncludeDigit,
    int idx,
    bool included,
  ) {
    if (idx == positions) {
      return remainingSum == 0 && included;
    }
    if (remainingSum <= 0) return false;

    final candidates = emptyCandidates[idx];
    int minPossible = 0;
    int maxPossible = 0;
    for (int i = idx; i < positions; i++) {
      minPossible += _getMinDigit(emptyCandidates[i], used);
      maxPossible += _getMaxDigit(emptyCandidates[i], used);
    }
    if (remainingSum < minPossible || remainingSum > maxPossible) return false;

    for (final digit in candidates) {
      if (used.contains(digit)) continue;
      if (digit > remainingSum) continue;
      used.add(digit);
      if (_dfs(
        positions,
        remainingSum - digit,
        used,
        emptyCandidates,
        mustIncludeDigit,
        idx + 1,
        included || (mustIncludeDigit == -1) || (digit == mustIncludeDigit),
      )) {
        used.remove(digit);
        return true;
      }
      used.remove(digit);
    }
    return false;
  }

  static int _getMinDigit(Set<int> candidates, Set<int> used) {
    for (int d = 1; d <= 9; d++) {
      if (candidates.contains(d) && !used.contains(d)) return d;
    }
    return 10;
  }

  static int _getMaxDigit(Set<int> candidates, Set<int> used) {
    for (int d = 9; d >= 1; d--) {
      if (candidates.contains(d) && !used.contains(d)) return d;
    }
    return 0;
  }


}
