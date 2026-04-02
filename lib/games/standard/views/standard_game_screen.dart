import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/standard/index.dart';

class StandardGameScreen
    extends
        GameScreenTemplate<
          StandardGameViewModel,
          AppSettings,
          FinishScreenTemplate<StandardGameViewModel, StandardGameService>
        > {
  const StandardGameScreen({super.key, super.autoLoadSavedGame = false});

  @override
  String getTitle(BuildContext context) =>
      LocalizationUtils.of(context)?.gameTypeStandardName ?? 'Standard Sudoku';

  @override
  FinishScreenTemplate<StandardGameViewModel, StandardGameService>
  createFinishScreen() => _StandardFinishScreen();

  @override
  GameLayout calculateLayout(Size gameAreaSize) =>
      LayoutCalculator.calculateStandardLayout(gameAreaSize);

  @override
  Widget buildBoard(
    BuildContext context,
    StandardGameViewModel viewModel,
    double cellSize,
  ) => StandardBoardWidget(
    board: viewModel.state.standardBoard,
    onCellSelected: (Cell cell) => viewModel.selectCellByObject(cell),
    cellSize: cellSize,
  );
}

class _StandardFinishScreen
    extends FinishScreenTemplate<StandardGameViewModel, StandardGameService> {
  @override
  String get gameType => 'standard';

  @override
  StandardGameViewModel getViewModel(BuildContext context) =>
      Provider.of<StandardGameViewModel>(context, listen: false);

  @override
  StandardGameService get gameService => StandardGameService();
}
