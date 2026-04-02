import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/index.dart';

class DiagonalGameScreen extends StatefulWidget {

  const DiagonalGameScreen({
    super.key,
    this.autoLoadSavedGame = false,
  });
  final bool autoLoadSavedGame;

  @override
  State<DiagonalGameScreen> createState() => _DiagonalGameScreenState();
}

class _DiagonalGameScreenState extends State<DiagonalGameScreen> {
  bool _showDiagonalLines = true;

  @override
  Widget build(BuildContext context) => _DiagonalGameScreenContent(
      autoLoadSavedGame: widget.autoLoadSavedGame,
      showDiagonalLines: _showDiagonalLines,
      onToggleDiagonalLines: () {
        setState(() {
          _showDiagonalLines = !_showDiagonalLines;
        });
      },
    );
}

class _DiagonalGameScreenContent
    extends
        GameScreenTemplate<
          DiagonalGameViewModel,
          AppSettings,
          FinishScreenTemplate<DiagonalGameViewModel, DiagonalGameService>
        > {

  const _DiagonalGameScreenContent({
    super.autoLoadSavedGame = false,
    required this.showDiagonalLines,
    required this.onToggleDiagonalLines,
  });
  final bool showDiagonalLines;
  final VoidCallback onToggleDiagonalLines;

  @override
  String getTitle(BuildContext context) =>
      LocalizationUtils.of(context)?.gameTypeDiagonalName ?? 'Diagonal Sudoku';

  @override
  FinishScreenTemplate<DiagonalGameViewModel, DiagonalGameService> createFinishScreen() => _DiagonalFinishScreen();

  @override
  GameLayout calculateLayout(Size gameAreaSize) =>
      LayoutCalculator.calculateStandardLayout(gameAreaSize);

  @override
  Widget buildBoard(
    BuildContext context,
    DiagonalGameViewModel viewModel,
    double cellSize,
  ) => DiagonalBoardWidget(
    board: viewModel.state.diagonalBoard,
    onCellSelected: (Cell cell) => viewModel.selectCellByObject(cell),
    cellSize: cellSize,
    showDiagonalLines: showDiagonalLines,
  );

  @override
  List<Widget>? buildTitleActions(BuildContext context, DiagonalGameViewModel viewModel) {
    final isDarkMode = context.isDarkMode;
    final iconColor = showDiagonalLines
        ? context.primaryColor
        : (isDarkMode ? Colors.white.withAlpha(150) : AppColors.mutedText);

    return [
      IconButton(
        icon: Icon(
          showDiagonalLines ? Icons.show_chart : Icons.show_chart_outlined,
          color: iconColor,
        ),
        onPressed: onToggleDiagonalLines,
        tooltip: showDiagonalLines ? '隐藏对角线' : '显示对角线',
      ),
    ];
  }
}

class _DiagonalFinishScreen extends FinishScreenTemplate<DiagonalGameViewModel, DiagonalGameService> {
  @override
  String get gameType => 'diagonal';

  @override
  DiagonalGameViewModel getViewModel(BuildContext context) => Provider.of<DiagonalGameViewModel>(context, listen: false);

  @override
  DiagonalGameService get gameService => DiagonalGameService();
}
