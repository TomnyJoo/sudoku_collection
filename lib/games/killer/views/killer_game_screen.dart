import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/killer/index.dart';

class KillerGameScreen
    extends
        GameScreenTemplate<
          KillerGameViewModel,
          AppSettings,
          FinishScreenTemplate<KillerGameViewModel, KillerGameService>
        > {
  const KillerGameScreen({super.key, super.autoLoadSavedGame = false});

  @override
  String getTitle(BuildContext context) =>
      LocalizationUtils.of(context)?.gameTypeKillerName ?? 'Killer Sudoku';

  @override
  FinishScreenTemplate<KillerGameViewModel, KillerGameService>
  createFinishScreen() => _KillerFinishScreen();

  @override
  GameLayout calculateLayout(Size gameAreaSize) =>
      LayoutCalculator.calculateStandardLayout(gameAreaSize);

  @override
  Widget buildBoard(
    BuildContext context,
    KillerGameViewModel viewModel,
    double cellSize,
  ) => KillerBoardWidget(
    board: viewModel.state.killerBoard,
    onCellSelected: (Cell cell) => viewModel.selectCellByObject(cell),
    cellSize: cellSize,
  );
}

class _KillerFinishScreen
    extends FinishScreenTemplate<KillerGameViewModel, KillerGameService> {
  @override
  String get gameType => 'killer';

  @override
  KillerGameViewModel getViewModel(BuildContext context) =>
      Provider.of<KillerGameViewModel>(context, listen: false);

  @override
  KillerGameService get gameService => KillerGameService();
}
