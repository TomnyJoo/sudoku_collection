import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/window/index.dart';

class WindowGameScreen
    extends
        GameScreenTemplate<
          WindowGameViewModel,
          AppSettings,
          FinishScreenTemplate<WindowGameViewModel, WindowGameService>
        > {
  const WindowGameScreen({super.key, super.autoLoadSavedGame = false});

  @override
  String getTitle(BuildContext context) =>
      LocalizationUtils.of(context)?.gameTypeWindowName ?? 'Window Sudoku';

  @override
  FinishScreenTemplate<WindowGameViewModel, WindowGameService>
  createFinishScreen() => _WindowFinishScreen();

  @override
  GameLayout calculateLayout(Size gameAreaSize) =>
      LayoutCalculator.calculateStandardLayout(gameAreaSize);

  @override
  Widget buildBoard(
    BuildContext context,
    WindowGameViewModel viewModel,
    double cellSize,
  ) => WindowBoardWidget(
    board: viewModel.state.windowBoard,
    onCellSelected: (Cell cell) => viewModel.selectCellByObject(cell),
    cellSize: cellSize,
  );
}

class _WindowFinishScreen
    extends FinishScreenTemplate<WindowGameViewModel, WindowGameService> {
  @override
  String get gameType => 'window';

  @override
  WindowGameViewModel getViewModel(BuildContext context) =>
      Provider.of<WindowGameViewModel>(context, listen: false);

  @override
  WindowGameService get gameService => WindowGameService();
}
