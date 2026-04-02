import 'dart:math';
import 'package:flutter/material.dart';

class GameLayout {
  GameLayout({
    required this.boardCellSize,
    required this.keypadCellSize,
    required this.isHorizontalLayout,
    required this.boardSize,
    required this.keypadWidth,
    required this.keypadHeight,
    required this.totalWidth,
    required this.totalHeight,
    required this.utilizationRatio,
  });

  final double boardCellSize;
  final double keypadCellSize;
  final bool isHorizontalLayout;
  final double boardSize;
  final double keypadWidth;
  final double keypadHeight;
  final double totalWidth;
  final double totalHeight;
  final double utilizationRatio;

  @override
  String toString() => 'GameLayout{布局: ${isHorizontalLayout ? '左右' : '上下'}, '
        '棋盘单元格: ${boardCellSize.toStringAsFixed(1)}, '
        '棋盘尺寸: ${boardSize.toStringAsFixed(1)}, '
        '键盘区: ${keypadWidth.toStringAsFixed(1)}×${keypadHeight.toStringAsFixed(1)}, '
        '利用率: ${(utilizationRatio * 100).toStringAsFixed(1)}%}';
}

class LayoutCalculator {
  static const double spacing = 8;
  static const double minBoardCellSize = 30;
  static const double minKeypadCellSize = 35;
  static const double keypadContainerPadding = 2;
  static const double keypadGridSpacing = 4;
  static const double keypadBottomMargin = 8;

  static GameLayout calculateOptimalLayout(
    final Size gameAreaSize,
  ) {
    final gameAreaWidth = gameAreaSize.width;
    final gameAreaHeight = gameAreaSize.height;

    final isHorizontalLayout = gameAreaWidth >= gameAreaHeight;

    GameLayout layout;
    if (isHorizontalLayout) {
      layout = _calculateHorizontalLayout(gameAreaWidth, gameAreaHeight);
    } else {
      layout = _calculateVerticalLayout(gameAreaWidth, gameAreaHeight);
    }

    return layout;
  }

  static GameLayout _calculateVerticalLayout(final double width, final double height) {
    var boardSize = (height - spacing - keypadBottomMargin) / 1.5;
    
    if (boardSize > width) {
      boardSize = width;
    }
    
    if (boardSize / 9 < minBoardCellSize) {
      boardSize = minBoardCellSize * 9;
    }

    final keypadWidth = boardSize;
    final keypadHeight = boardSize * 0.5;

    final boardCellSize = boardSize / 9;

    final eachKeypadWidth = keypadWidth / 2;
    final eachKeypadHeight = keypadHeight;
    
    final keypadCellSizeByWidth = (eachKeypadWidth - keypadContainerPadding * 2 - keypadGridSpacing * 2) / 3;
    final keypadCellSizeByHeight = (eachKeypadHeight - keypadContainerPadding * 2 - keypadGridSpacing * 2) / 3;
    
    double keypadCellSize = min(keypadCellSizeByWidth, keypadCellSizeByHeight);
    
    if (keypadCellSize < minKeypadCellSize) {
      keypadCellSize = minKeypadCellSize;
    }

    final totalHeight = boardSize + spacing + keypadHeight + keypadBottomMargin;
    final totalWidth = boardSize;
    final utilizationRatio = (boardSize * boardSize + keypadWidth * keypadHeight) / (width * height);

    return GameLayout(
      boardCellSize: boardCellSize,
      keypadCellSize: keypadCellSize,
      isHorizontalLayout: false,
      boardSize: boardSize,
      keypadWidth: keypadWidth,
      keypadHeight: keypadHeight,
      totalWidth: totalWidth,
      totalHeight: totalHeight,
      utilizationRatio: utilizationRatio,
    );
  }

  static GameLayout _calculateHorizontalLayout(final double width, final double height) {
    var boardSize = (width - spacing) / 1.5;
    
    if (boardSize > height) {
      boardSize = height;
    }
    
    if (boardSize / 9 < minBoardCellSize) {
      boardSize = minBoardCellSize * 9;
    }

    final keypadHeight = boardSize;
    final keypadWidth = boardSize * 0.5;

    final boardCellSize = boardSize / 9;

    final eachKeypadWidth = keypadWidth;
    final eachKeypadHeight = keypadHeight / 2;
    
    final keypadCellSizeByWidth = (eachKeypadWidth - keypadContainerPadding * 2 - keypadGridSpacing * 2) / 3;
    final keypadCellSizeByHeight = (eachKeypadHeight - keypadContainerPadding * 2 - keypadGridSpacing * 2) / 3;
    
    double keypadCellSize = min(keypadCellSizeByWidth, keypadCellSizeByHeight);
    
    if (keypadCellSize < minKeypadCellSize) {
      keypadCellSize = minKeypadCellSize;
    }

    final totalWidth = boardSize + spacing + keypadWidth;
    final totalHeight = boardSize;
    final utilizationRatio = (boardSize * boardSize + keypadWidth * keypadHeight) / (width * height);

    return GameLayout(
      boardCellSize: boardCellSize,
      keypadCellSize: keypadCellSize,
      isHorizontalLayout: true,
      boardSize: boardSize,
      keypadWidth: keypadWidth,
      keypadHeight: keypadHeight,
      totalWidth: totalWidth,
      totalHeight: totalHeight,
      utilizationRatio: utilizationRatio,
    );
  }

  static GameLayout calculateStandardLayout(final Size availableSize) =>
    calculateOptimalLayout(availableSize);

  static GameLayout calculateJigsawLayout(final Size availableSize) =>
    calculateOptimalLayout(availableSize);

  static GameLayout calculateDiagonalLayout(final Size availableSize) =>
    calculateOptimalLayout(availableSize);

  static GameLayout calculateSamuraiLayout(final Size availableSize) =>
    calculateOptimalLayout(availableSize);
}
