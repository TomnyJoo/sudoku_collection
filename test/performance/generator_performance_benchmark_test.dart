import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/models/index.dart';
import 'package:sudoku/core/processors/index.dart';
import 'package:sudoku/games/diagonal/diagonal_generator.dart';
import 'package:sudoku/games/standard/standard_generator.dart';
import 'package:sudoku/games/window/window_generator.dart';

/// 生成器性能基准测试
///
/// 测试优化前后的性能对比：
/// - 生成速度（毫秒）
/// - 成功率（%）
/// - 平均尝试次数
void main() {
  group('生成器性能基准测试', () {
    const int sampleSize = 10; // 每个难度测试样本数

    /// 运行性能测试
    Future<BenchmarkResult> runBenchmark({
      required IGameGenerator generator,
      required Difficulty difficulty,
      required int size,
      required int sampleCount,
    }) async {
      final times = <int>[];
      int successCount = 0;

      for (int i = 0; i < sampleCount; i++) {
        final stopwatch = Stopwatch()..start();
        try {
          await generator.generate(difficulty: difficulty, size: size);
          stopwatch.stop();

          times.add(stopwatch.elapsedMilliseconds);
          successCount++;
        } catch (e) {
          stopwatch.stop();
        }
      }

      return BenchmarkResult(
        avgTimeMs: times.isEmpty
            ? 0
            : times.reduce((a, b) => a + b) ~/ times.length,
        minTimeMs: times.isEmpty ? 0 : times.reduce((a, b) => a < b ? a : b),
        maxTimeMs: times.isEmpty ? 0 : times.reduce((a, b) => a > b ? a : b),
        successRate: successCount / sampleCount,
        sampleCount: sampleCount,
      );
    }

    group('标准数独生成器', () {
      late StandardGenerator generator;

      setUp(() {
        generator = StandardGenerator();
      });

      test('各难度性能基准', () async {
        AppLogger.info('\n=== 标准数独生成器性能基准 ===');
        AppLogger.info('样本数: $sampleSize');
        AppLogger.info('');

        for (final difficulty in [
          Difficulty.easy,
          Difficulty.medium,
          Difficulty.hard,
          Difficulty.expert,
          Difficulty.master,
        ]) {
          final result = await runBenchmark(
            generator: generator,
            difficulty: difficulty,
            size: 9,
            sampleCount: sampleSize,
          );

          AppLogger.info('难度: ${difficulty.name}');
          AppLogger.info('  平均时间: ${result.avgTimeMs}ms');
          AppLogger.info('  最短时间: ${result.minTimeMs}ms');
          AppLogger.info('  最长时间: ${result.maxTimeMs}ms');
          AppLogger.info(
            '  成功率: ${(result.successRate * 100).toStringAsFixed(1)}%',
          );
          AppLogger.info('');
        }
      });

      test('高难度生成成功率测试', () async {
        AppLogger.info('\n=== 高难度生成成功率测试（Master难度）===');

        const int highDifficultySamples = 20;
        int successCount = 0;
        final times = <int>[];

        for (int i = 0; i < highDifficultySamples; i++) {
          final stopwatch = Stopwatch()..start();
          try {
            final result = await generator.generate(
              difficulty: Difficulty.master,
              size: 9,
            );
            stopwatch.stop();

            // 验证唯一解
            final dlxSolver = StandardDLXSolver.create();
            final count = dlxSolver.countSolutions(result.puzzle);

            if (count == 1) {
              successCount++;
              times.add(stopwatch.elapsedMilliseconds);
            }
          } catch (e) {
            stopwatch.stop();
          }
        }

        final successRate = successCount / highDifficultySamples;
        final avgTime = times.isEmpty
            ? 0
            : times.reduce((a, b) => a + b) ~/ times.length;

        AppLogger.info('样本数: $highDifficultySamples');
        AppLogger.info('成功生成: $successCount');
        AppLogger.info('成功率: ${(successRate * 100).toStringAsFixed(1)}%');
        AppLogger.info('平均时间: ${avgTime}ms');
        AppLogger.info('');

        // 断言：成功率应该 >= 95%
        expect(
          successRate,
          greaterThanOrEqualTo(0.95),
          reason: 'Master难度成功率应该 >= 95%',
        );
      });
    });

    group('对角线数独生成器', () {
      late DiagonalGenerator generator;

      setUp(() {
        generator = DiagonalGenerator();
      });

      test('各难度性能基准', () async {
        AppLogger.info('\n=== 对角线数独生成器性能基准 ===');
        AppLogger.info('样本数: $sampleSize');
        AppLogger.info('');

        for (final difficulty in [
          Difficulty.medium,
          Difficulty.hard,
          Difficulty.expert,
        ]) {
          final result = await runBenchmark(
            generator: generator,
            difficulty: difficulty,
            size: 9,
            sampleCount: sampleSize,
          );

          AppLogger.info('难度: ${difficulty.name}');
          AppLogger.info('  平均时间: ${result.avgTimeMs}ms');
          AppLogger.info('  最短时间: ${result.minTimeMs}ms');
          AppLogger.info('  最长时间: ${result.maxTimeMs}ms');
          AppLogger.info('  成功率: ${(result.successRate * 100).toStringAsFixed(1)}%');
          AppLogger.info('');
        }
      });
    });

    group('窗口数独生成器', () {
      late WindowGenerator generator;

      setUp(() {
        generator = WindowGenerator();
      });

      test('各难度性能基准', () async {
        AppLogger.info('\n=== 窗口数独生成器性能基准 ===');
        AppLogger.info('样本数: $sampleSize');
        AppLogger.info('');

        for (final difficulty in [
          Difficulty.medium,
          Difficulty.hard,
          Difficulty.expert,
        ]) {
          final result = await runBenchmark(
            generator: generator,
            difficulty: difficulty,
            size: 9,
            sampleCount: sampleSize,
          );

          AppLogger.info('难度: ${difficulty.name}');
          AppLogger.info('  平均时间: ${result.avgTimeMs}ms');
          AppLogger.info('  最短时间: ${result.minTimeMs}ms');
          AppLogger.info('  最长时间: ${result.maxTimeMs}ms');
          AppLogger.info('  成功率: ${(result.successRate * 100).toStringAsFixed(1)}%');
          AppLogger.info('');
        }
      });
    });

    group('性能对比总结', () {
      test('生成速度对比', () async {
        AppLogger.info('\n=== 生成速度对比（Hard难度）===');

        final generators = [
          ('标准数独', StandardGenerator()),
          ('对角线数独', DiagonalGenerator()),
          ('窗口数独', WindowGenerator()),
        ];

        for (final (name, generator) in generators) {
          final times = <int>[];

          for (int i = 0; i < 5; i++) {
            final stopwatch = Stopwatch()..start();
            await generator.generate(difficulty: Difficulty.hard, size: 9);
            stopwatch.stop();
            times.add(stopwatch.elapsedMilliseconds);
          }

          final avgTime = times.reduce((a, b) => a + b) ~/ times.length;
          AppLogger.info('$name: ${avgTime}ms (样本: ${times.join(", ")}ms)');
        }

        AppLogger.info('');
        AppLogger.info('预期目标:');
        AppLogger.info('  - 标准数独: < 200ms');
        AppLogger.info('  - 对角线数独: < 300ms');
        AppLogger.info('  - 窗口数独: < 300ms');
      });
    });
  });
}

/// 基准测试结果
class BenchmarkResult {
  BenchmarkResult({
    required this.avgTimeMs,
    required this.minTimeMs,
    required this.maxTimeMs,
    required this.successRate,
    required this.sampleCount,
  });

  final int avgTimeMs;
  final int minTimeMs;
  final int maxTimeMs;
  final double successRate;
  final int sampleCount;
}
