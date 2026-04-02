import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/index.dart';

class DiagonalCustomGameScreen extends StatefulWidget {
  const DiagonalCustomGameScreen({super.key});

  @override
  State<DiagonalCustomGameScreen> createState() =>
      _DiagonalCustomGameScreenState();
}

class _DiagonalCustomGameScreenState extends State<DiagonalCustomGameScreen> {
  late List<List<Cell>> _board;
  Cell? _selectedCell;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    _board = List.generate(
      DiagonalConstants.boardSize,
      (final row) => List.generate(DiagonalConstants.boardSize, (final col) => Cell(row: row, col: col)),
    );
  }

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) {
      final availableWidth = constraints.maxWidth;
      final availableHeight = constraints.maxHeight;

      final isHorizontalLayout = availableWidth >= availableHeight;

      final gameAreaWidth = availableWidth;
      final gameAreaHeight = isHorizontalLayout
          ? availableHeight - kToolbarHeight
          : availableHeight - kToolbarHeight - 60;

      final layout = LayoutCalculator.calculateStandardLayout(
        Size(gameAreaWidth, gameAreaHeight),
      );

      return Scaffold(
        appBar: !layout.isHorizontalLayout
            ? AppBar(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  LocalizationUtils.of(context)?.customGame ?? 'Custom Game',
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showSettings(context),
                  ),
                ],
              )
            : null,
        body: _buildGameLayout(
          context,
          availableWidth,
          availableHeight,
          layout,
        ),
      );
    },
  );

  Widget _buildGameLayout(
    final BuildContext context,
    final double availableWidth,
    final double availableHeight,
    final GameLayout layout,
  ) {
    if (layout.isHorizontalLayout) {
      return _buildHorizontalLayout(context, layout);
    } else {
      return _buildVerticalLayout(context, layout);
    }
  }

  Widget _buildHorizontalLayout(
    final BuildContext context,
    final GameLayout layout,
  ) => Column(
    children: [
      Container(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.cardColor.withAlpha(180),
          border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(51))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Text(
              LocalizationUtils.of(context)?.customGame ?? 'Custom Game',
              style: TextStyle(
                fontSize: AppTextStyles.fontSizeButton,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            _buildInstructionsRow(),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
      ),
      Expanded(
        child: LayoutBuilder(
          builder: (final context, final constraints) =>
              _buildHorizontalGameArea(context, layout, constraints),
        ),
      ),
    ],
  );

  Widget _buildVerticalLayout(
    final BuildContext context,
    final GameLayout layout,
  ) => Column(
      children: [
        _buildInstructionsBar(),
        Expanded(
          child: LayoutBuilder(
            builder: (final context, final constraints) =>
                _buildVerticalGameArea(context, layout, constraints),
          ),
        ),
      ],
  );

  Widget _buildInstructionsBar() {
    final isDarkMode = context.isDarkMode;
    final responsiveBorderRadius = ResponsiveLayout.getResponsiveBorderRadius(
      context,
    );
    final localization = LocalizationUtils.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  context.primaryColor.withAlpha(51),
                  context.primaryColor.withAlpha(26),
                ]
              : [Colors.white.withAlpha(38), Colors.white.withAlpha(13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        border: Border.all(
          color: isDarkMode
              ? context.borderColor.withAlpha(102)
              : Colors.white.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInstructionItem(
            Icons.touch_app,
            localization?.customGameInstruction1 ?? 'Tap cells to select them',
          ),
          const SizedBox(width: 16),
          _buildInstructionItem(
            Icons.dialpad,
            localization?.customGameInstruction2 ??
                'Use number keys to fill in numbers',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsRow() {
    final localization = LocalizationUtils.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInstructionItem(
          Icons.touch_app,
          localization?.customGameInstruction1 ?? 'Tap cells to select them',
        ),
        const SizedBox(width: 16),
        _buildInstructionItem(
          Icons.dialpad,
          localization?.customGameInstruction2 ??
              'Use number keys to fill in numbers',
        ),
      ],
    );
  }

  Widget _buildInstructionItem(final IconData icon, final String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: context.primaryColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: AppTextStyles.fontSizeLabel,
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );

  Widget _buildHorizontalGameArea(
    final BuildContext context,
    final GameLayout layout,
    final BoxConstraints constraints,
  ) {
    final diagonalBoard = DiagonalBoard(size: DiagonalConstants.boardSize, cells: _board);
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;

    return Stack(
      children: [
        Positioned(
          left: (availableWidth - layout.boardSize - LayoutCalculator.spacing - layout.keypadWidth) / 2,
          top: (availableHeight - layout.boardSize) / 2,
          child: SizedBox(
            width: layout.boardSize,
            height: layout.boardSize,
            child: DiagonalBoardWidget(
              board: diagonalBoard,
              onCellSelected: _onCellSelected,
              cellSize: layout.boardCellSize,
            ),
          ),
       ),
        Positioned(
          left: (availableWidth - layout.boardSize - LayoutCalculator.spacing - layout.keypadWidth) / 2 + layout.boardSize + LayoutCalculator.spacing,
          top: (availableHeight - layout.keypadHeight) / 2,
          child: SizedBox(
            width: layout.keypadWidth,
            height: layout.keypadHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: layout.keypadHeight / 2,
                  child: DiagonalCustomGameFunctionKeyboard(
                    onStartGame: _validateAndStartGame,
                    onClearBoard: _showClearConfirmDialog,
                    isValidating: _isValidating,
                    buttonSize: layout.keypadCellSize,
                  ),
                ),
                SizedBox(
                  height: layout.keypadHeight / 2,
                  child: DiagonalCustomGameNumberKeyboard(
                    onNumberSelected: _onNumberSelected,
                    buttonSize: layout.keypadCellSize,
                    board: diagonalBoard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalGameArea(
    final BuildContext context,
    final GameLayout layout,
    final BoxConstraints constraints,
  ) {
    final diagonalBoard = DiagonalBoard(size: DiagonalConstants.boardSize, cells: _board);
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;

    return Stack(
      children: [
        Positioned(
          left: (availableWidth - layout.boardSize) / 2,
          top: (availableHeight - layout.boardSize - LayoutCalculator.spacing - layout.keypadHeight) / 2,
          child: SizedBox(
            width: layout.boardSize,
            height: layout.boardSize,
            child: DiagonalBoardWidget(
              board: diagonalBoard,
              onCellSelected: _onCellSelected,
              cellSize: layout.boardCellSize,
            ),
          ),
        ),
        Positioned(
          left: (availableWidth - layout.keypadWidth) / 2,
          top: (availableHeight - layout.boardSize - LayoutCalculator.spacing - layout.keypadHeight - LayoutCalculator.keypadBottomMargin) / 2 + layout.boardSize + LayoutCalculator.spacing,
          child: SizedBox(
            width: layout.keypadWidth,
            height: layout.keypadHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: layout.keypadWidth / 2,
                  child: DiagonalCustomGameFunctionKeyboard(
                    onStartGame: _validateAndStartGame,
                    onClearBoard: _showClearConfirmDialog,
                    isValidating: _isValidating,
                    buttonSize: layout.keypadCellSize,
                  ),
                ),
                SizedBox(
                  width: layout.keypadWidth / 2,
                  child: DiagonalCustomGameNumberKeyboard(
                    onNumberSelected: _onNumberSelected,
                    buttonSize: layout.keypadCellSize,
                    board: diagonalBoard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onCellSelected(final Cell cell) {
    setState(() {
      _selectedCell = cell;
      _updateSelection();
    });
  }

  void _onNumberSelected(final int? number) {
    if (_selectedCell == null) return;
    setState(() {
      final row = _selectedCell!.row;
      final col = _selectedCell!.col;
      if (_board[row][col].value == number) {
        _board[row][col] = _board[row][col].clear();
      } else {
        _board[row][col] = _board[row][col].setValue(number);
      }
      _updateSelection();
    });
  }

  void _updateSelection() {
    final selectedValue = _selectedCell != null
        ? _board[_selectedCell!.row][_selectedCell!.col].value
        : null;
    _board = _board
        .map(
          (final row) => row
              .map(
                (final cell) => cell.copyWith(
                  isSelected:
                      _selectedCell != null &&
                      cell.row == _selectedCell!.row &&
                      cell.col == _selectedCell!.col,
                  isHighlighted:
                      selectedValue != null && cell.value == selectedValue,
                ),
              )
              .toList(),
        )
        .toList();
  }

  void _showClearConfirmDialog() {
    final localization = LocalizationUtils.of(context);
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(localization?.clearBoard ?? 'Clear Board'),
        content: Text(
          localization?.clearBoardConfirm ??
              'Are you sure you want to clear the board?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeBoard();
                _selectedCell = null;
              });
            },
            child: Text(localization?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndStartGame() async {
    final localization = LocalizationUtils.of(context);
    final validator = GameValidator();

    if (_isValidating) return;

    setState(() {
      _isValidating = true;
    });

    try {
      final filledCells = _board
          .expand((final row) => row)
          .where((final cell) => cell.value != null)
          .length;

      if (filledCells < DiagonalConstants.minFilledCells) {
        _showErrorDialog(
          localization?.customGameErrorTooFew ??
              'Please fill in at least 17 cells.',
        );
        setState(() {
          _isValidating = false;
        });
        return;
      }

      final tempBoard = DiagonalBoard(size: DiagonalConstants.boardSize, cells: _board);
      if (!validator.validateBoard(tempBoard)) {
        _showErrorDialog(
          localization?.customGameErrorInvalid ??
              'Invalid board: Some numbers conflict with each other.',
        );
        setState(() {
          _isValidating = false;
        });
        return;
      }

      final hasUniqueSolution = await _checkUniqueSolution();

      if (!hasUniqueSolution) {
        _showErrorDialog(
          localization?.customGameErrorMultipleSolutions ??
              'This board has multiple solutions. Please add more numbers.',
        );
        setState(() {
          _isValidating = false;
        });
        return;
      }

      if (!mounted) return;

      final initialBoard = DiagonalBoard(
        size: DiagonalConstants.boardSize,
        cells: _board
            .map(
              (row) => row
                  .map((cell) => cell.copyWith(isFixed: cell.value != null))
                  .toList(),
            )
            .toList(),
      );

      final gameVM = context.read<DiagonalGameViewModel>();
      await gameVM.startCustomGame(initialBoard);

      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (final context) => const DiagonalGameScreen(),
        ),
      );
    } catch (e) {
      _showErrorDialog('${localization?.customGameError ?? 'Error'}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  Future<bool> _checkUniqueSolution() async {
    final board = _board
        .map((final row) => row.map((final cell) => cell.value ?? 0).toList())
        .toList();

    var solutionCount = 0;
    final result = await _countSolutions(board, 0, 0, DiagonalConstants.maxSolutionsToCheck);
    solutionCount = result;

    return solutionCount == 1;
  }

  Future<int> _countSolutions(
    final List<List<int>> board,
    final int row,
    final int col,
    final int maxSolutions,
  ) async {
    if (row == DiagonalConstants.boardSize) return 1;

    final nextRow = col == DiagonalConstants.boardSize - 1 ? row + 1 : row;
    final nextCol = col == DiagonalConstants.boardSize - 1 ? 0 : col + 1;

    if (board[row][col] != 0) {
      return _countSolutions(board, nextRow, nextCol, maxSolutions);
    }

    var solutions = 0;
    for (var num = 1; num <= DiagonalConstants.boardSize; num++) {
      if (_isValidPlacementForSolver(board, row, col, num)) {
        board[row][col] = num;
        solutions += await _countSolutions(
          board,
          nextRow,
          nextCol,
          maxSolutions,
        );
        board[row][col] = 0;

        if (solutions >= maxSolutions) {
          return solutions;
        }
      }
    }

    return solutions;
  }

  bool _isValidPlacementForSolver(
    final List<List<int>> board,
    final int row,
    final int col,
    final int num,
  ) {
    for (var i = 0; i < DiagonalConstants.boardSize; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }

    final startRow = (row ~/ DiagonalConstants.boxSize) * DiagonalConstants.boxSize;
    final startCol = (col ~/ DiagonalConstants.boxSize) * DiagonalConstants.boxSize;
    for (var i = 0; i < DiagonalConstants.boxSize; i++) {
      for (var j = 0; j < DiagonalConstants.boxSize; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }

    return true;
  }

  void _showErrorDialog(final String message) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(LocalizationUtils.of(context)?.error ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationUtils.of(context)?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings(final BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }
}

class DiagonalCustomGameFunctionKeyboard extends StatelessWidget {
  const DiagonalCustomGameFunctionKeyboard({
    required this.onStartGame,
    required this.onClearBoard,
    required this.isValidating,
    required this.buttonSize,
    super.key,
  });

  final VoidCallback onStartGame;
  final VoidCallback onClearBoard;
  final bool isValidating;
  final double buttonSize;

  @override
  Widget build(final BuildContext context) {
    const spacing = DiagonalConstants.functionKeyboardSpacing;
    const padding = DiagonalConstants.functionKeyboardPadding;

    return Container(
      padding: const EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: spacing),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.successColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DiagonalConstants.functionKeyboardBorderRadius),
                  ),
                ),
                onPressed: isValidating ? null : onStartGame,
                child: isValidating
                    ? const SizedBox(
                        width: DiagonalConstants.progressIndicatorWidth,
                        height: DiagonalConstants.progressIndicatorHeight,
                        child: CircularProgressIndicator(
                          strokeWidth: DiagonalConstants.progressIndicatorStrokeWidth,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.play_arrow, size: buttonSize * DiagonalConstants.functionKeyboardIconScale),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: spacing),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.errorColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DiagonalConstants.functionKeyboardBorderRadius),
                  ),
                ),
                onPressed: onClearBoard,
                child: Icon(Icons.clear, size: buttonSize * DiagonalConstants.functionKeyboardIconScale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
