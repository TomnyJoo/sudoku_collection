import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/jigsaw/index.dart';

class JigsawGameScreen extends StatefulWidget {
  const JigsawGameScreen({super.key, this.autoLoadSavedGame = false});
  final bool autoLoadSavedGame;

  @override
  State<JigsawGameScreen> createState() => _JigsawGameScreenState();
}

class _JigsawGameScreenState extends State<JigsawGameScreen> {
  bool _showRegionNumbers = true;

  @override
  Widget build(BuildContext context) => _JigsawGameScreenContent(
    autoLoadSavedGame: widget.autoLoadSavedGame,
    showRegionNumbers: _showRegionNumbers,
    onToggleRegionNumbers: () {
      setState(() {
        _showRegionNumbers = !_showRegionNumbers;
      });
    },
  );
}

class _JigsawGameScreenContent
    extends
        GameScreenTemplate<
          JigsawGameViewModel,
          AppSettings,
          FinishScreenTemplate<JigsawGameViewModel, JigsawGameService>
        > {
  const _JigsawGameScreenContent({
    super.autoLoadSavedGame = false,
    required this.showRegionNumbers,
    required this.onToggleRegionNumbers,
  });
  final bool showRegionNumbers;
  final VoidCallback onToggleRegionNumbers;

  @override
  String getTitle(BuildContext context) =>
      LocalizationUtils.of(context)?.gameTypeJigsawName ?? 'Jigsaw Sudoku';

  @override
  FinishScreenTemplate<JigsawGameViewModel, JigsawGameService>
  createFinishScreen() => _JigsawFinishScreen();

  @override
  GameLayout calculateLayout(Size gameAreaSize) =>
      LayoutCalculator.calculateStandardLayout(gameAreaSize);

  @override
  Widget buildBoard(
    BuildContext context,
    JigsawGameViewModel viewModel,
    double cellSize,
  ) => JigsawBoardWidget(
    board: viewModel.state.jigsawBoard,
    onCellSelected: (Cell cell) => viewModel.selectCellByObject(cell),
    cellSize: cellSize,
    showRegionNumbers: showRegionNumbers,
  );

  @override
  List<Widget>? buildTitleActions(
    BuildContext context,
    JigsawGameViewModel viewModel,
  ) {
    final isDarkMode = context.isDarkMode;
    final iconColor = showRegionNumbers
        ? context.primaryColor
        : (isDarkMode ? Colors.white.withAlpha(150) : AppColors.mutedText);

    return [
      IconButton(
        icon: Icon(
          showRegionNumbers ? Icons.grid_on : Icons.grid_off,
          color: iconColor,
        ),
        onPressed: onToggleRegionNumbers,
        tooltip: showRegionNumbers ? '隐藏区域编号' : '显示区域编号',
      ),
    ];
  }
}

class _JigsawFinishScreen
    extends FinishScreenTemplate<JigsawGameViewModel, JigsawGameService> {
  @override
  String get gameType => 'jigsaw';

  @override
  JigsawGameViewModel getViewModel(BuildContext context) =>
      Provider.of<JigsawGameViewModel>(context, listen: false);

  @override
  JigsawGameService get gameService => JigsawGameService();
}
