import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/samurai/index.dart';

class SamuraiGameScreen extends StatefulWidget {

  const SamuraiGameScreen({
    super.key,
    this.autoLoadSavedGame = false,
  });
  final bool autoLoadSavedGame;

  @override
  State<SamuraiGameScreen> createState() => _SamuraiGameScreenState();
}

class _SamuraiGameScreenState extends State<SamuraiGameScreen> {
  @override
  Widget build(BuildContext context) => _SamuraiGameScreenContent(
      autoLoadSavedGame: widget.autoLoadSavedGame,
    );
}

class _SamuraiGameScreenContent
    extends
        GameScreenTemplate<
          SamuraiGameViewModel,
          AppSettings,
          FinishScreenTemplate<SamuraiGameViewModel, SamuraiGameService>
        > {
  const _SamuraiGameScreenContent({
    super.autoLoadSavedGame = false,
  });

  @override
  String getTitle(BuildContext context) =>
      LocalizationUtils.of(context)?.gameTypeSamuraiName ?? 'Samurai Sudoku';

  @override
  FinishScreenTemplate<SamuraiGameViewModel, SamuraiGameService> createFinishScreen() => _SamuraiFinishScreen();

  @override
  GameLayout calculateLayout(Size gameAreaSize) =>
      LayoutCalculator.calculateStandardLayout(gameAreaSize);

  @override
  Widget buildBoard(
    BuildContext context,
    SamuraiGameViewModel viewModel,
    double cellSize,
  ) {
    if (viewModel.isOverviewMode) {
      return SamuraiOverviewBoard(
        board: viewModel.state.board,
        solution: viewModel.state.solution,
        isShowingSolution: viewModel.state.isShowingSolution,
        onCellSelected: (Cell cell) => viewModel.selectCellByObject(cell),
        currentSubGridIndex: viewModel.state.currentSubGridIndex,
        cellSize: cellSize * 0.6,
        onSubGridSelected: (int index) async {
          await viewModel.switchSubGrid(index);
          viewModel.exitOverviewMode();
        },
      );
    }
    
    return _SwipeableSamuraiBoard(
      viewModel: viewModel,
      cellSize: cellSize,
    );
  }

  @override
  List<Widget>? buildTitleActions(BuildContext context, SamuraiGameViewModel viewModel) {
    final isDarkMode = context.isDarkMode;
    final iconColor = isDarkMode ? Colors.white.withAlpha(200) : AppColors.mutedText;
    final subGridNames = ['左上', '右上', '左下', '右下', '中心'];
    final currentIndex = viewModel.state.currentSubGridIndex;

    return [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final prevIndex = (currentIndex - 1 + 5) % 5;
                    await viewModel.switchSubGrid(prevIndex);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: iconColor.withAlpha(200),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  subGridNames[currentIndex],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor.withAlpha(200),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final nextIndex = (currentIndex + 1) % 5;
                    await viewModel.switchSubGrid(nextIndex);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: iconColor.withAlpha(200),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 4),
      // 概览模式切换按钮
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => viewModel.toggleOverviewMode(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: viewModel.isOverviewMode
                  ? iconColor.withAlpha(50)
                  : iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              viewModel.isOverviewMode ? Icons.zoom_in : Icons.zoom_out_map,
              size: 18,
              color: iconColor.withAlpha(200),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  List<Widget>? buildExtraStatItems(BuildContext context, AppSettings settings) {
    final viewModel = Provider.of<SamuraiGameViewModel>(context, listen: false);
    
    if (viewModel.isOverviewMode) {
      return [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(50),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 3),
                Text(
                  '点击子网格进入编辑',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return null;
  }
}

/// 支持滑动手势的武士数独棋盘组件
class _SwipeableSamuraiBoard extends StatefulWidget {

  const _SwipeableSamuraiBoard({
    required this.viewModel,
    required this.cellSize,
  });
  final SamuraiGameViewModel viewModel;
  final double cellSize;

  @override
  State<_SwipeableSamuraiBoard> createState() => _SwipeableSamuraiBoardState();
}

class _SwipeableSamuraiBoardState extends State<_SwipeableSamuraiBoard> {
  static const double _swipeThreshold = 50.0;

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    final currentIndex = widget.viewModel.state.currentSubGridIndex;
    
    // 根据滑动速度判断方向
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! < -_swipeThreshold) {
        // 向左滑动，切换到下一个子网格
        final nextIndex = (currentIndex + 1) % 5;
        await widget.viewModel.switchSubGrid(nextIndex);
      } else if (details.primaryVelocity! > _swipeThreshold) {
        // 向右滑动，切换到上一个子网格
        final prevIndex = (currentIndex - 1 + 5) % 5;
        await widget.viewModel.switchSubGrid(prevIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SamuraiBoardWidget(
        board: widget.viewModel.state.board,
        solution: widget.viewModel.state.solution,
        isShowingSolution: widget.viewModel.state.isShowingSolution,
        currentSubGridIndex: widget.viewModel.state.currentSubGridIndex,
        onCellSelected: (Cell cell) => widget.viewModel.selectCellByObject(cell),
        cellSize: widget.cellSize,
      ),
    );
}

class _SamuraiFinishScreen extends FinishScreenTemplate<SamuraiGameViewModel, SamuraiGameService> {
  @override
  String get gameType => 'samurai';

  @override
  SamuraiGameViewModel getViewModel(BuildContext context) => Provider.of<SamuraiGameViewModel>(context, listen: false);

  @override
  SamuraiGameService get gameService => SamuraiGameService();
}
