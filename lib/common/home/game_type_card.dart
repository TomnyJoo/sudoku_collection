import 'package:flutter/material.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/index.dart';

/// 游戏类型卡片
class GameTypeCard extends StatefulWidget {
  const GameTypeCard({
    required this.gameType,
    required this.title,
    required this.icon,
    required this.color,
    required this.showCustomGame,
    required this.onDifficultySelected,
    required this.onLoadGame,
    this.onCustomGame,
    this.isCompact = false,
    this.hasSavedGame = false,
    super.key,
  });
  final GameType gameType;
  final String title;
  final IconData icon;
  final Color color;
  final bool showCustomGame;
  final void Function(Difficulty) onDifficultySelected;
  final VoidCallback onLoadGame;
  final VoidCallback? onCustomGame;
  final bool isCompact;
  final bool hasSavedGame;

  @override
  State<GameTypeCard> createState() => _GameTypeCardState();
}

/// 游戏类型卡片状态
class _GameTypeCardState extends State<GameTypeCard>
    with SingleTickerProviderStateMixin {

  // ========== 变量 ==========
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  // ========== 方法 ==========

  /// 初始化
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  /// 销毁动画
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 处理按下事件
  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  /// 处理抬起事件
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  /// 处理取消事件  
  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  /// 构建游戏类型卡片
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: _onTapDown,
    onTapUp: _onTapUp,
    onTapCancel: _onTapCancel,
    child: AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.color, widget.color.withAlpha(220)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(_isPressed ? 80 : 50),
              blurRadius: _isPressed ? 6 : 12,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(_isPressed ? 10 : 20),
              blurRadius: _isPressed ? 2 : 4,
              offset: Offset(0, _isPressed ? 1 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.isCompact
              ? _buildCompactContent(context)
              : _buildStandardContent(context),
        ),
      ),
    ),
  );

  /// 构建紧凑布局的游戏类型卡片
  Widget _buildCompactContent(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeader(context, isCompact: true),
        const SizedBox(height: 6),
        DifficultyButtonGrid(
          gameType: widget.gameType,
          onDifficultySelected: widget.onDifficultySelected,
          isCompact: true,
          baseColor: widget.color,
        ),
        const SizedBox(height: 6),
        _buildActionButtons(context, isCompact: true),
      ],
    ),
  );

  /// 构建标准布局的游戏类型卡片
  Widget _buildStandardContent(BuildContext context) => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        DifficultyButtonGrid(
          gameType: widget.gameType,
          onDifficultySelected: widget.onDifficultySelected,
          baseColor: widget.color,
        ),
        const SizedBox(height: 8),
        _buildActionButtons(context),
      ],
    ),
  );

  /// 构建紧凑布局的游戏类型卡片标题
  Widget _buildHeader(BuildContext context, {bool isCompact = false}) {
    final iconSize = isCompact ? 22.0 : 28.0;
    final titleFontSize = isCompact ? 12.0 : 14.0;
    final spacing = isCompact ? 4.0 : 6.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icon, size: iconSize, color: Colors.white),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建紧凑布局的游戏类型卡片操作按钮
  Widget _buildActionButtons(BuildContext context, {bool isCompact = false}) {
    final localizations = LocalizationUtils.of(context);
    final loadGameLabel = localizations?.loadGame ?? '加载游戏';
    final customGameLabel = localizations?.customGame ?? '自定义';

    if (isCompact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.hasSavedGame)
            _buildCompactActionButton(
              context,
              icon: Icons.folder_open,
              label: loadGameLabel,
              onTap: widget.onLoadGame,
            ),
          if (widget.showCustomGame && widget.onCustomGame != null) ...[
            if (widget.hasSavedGame) const SizedBox(width: 6),
            _buildCompactActionButton(
              context,
              icon: Icons.edit,
              label: customGameLabel,
              onTap: widget.onCustomGame!,
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.hasSavedGame)
          _buildActionButton(
            context,
            icon: Icons.folder_open,
            label: loadGameLabel,
            onTap: widget.onLoadGame,
          ),
        if (widget.showCustomGame && widget.onCustomGame != null) ...[
          if (widget.hasSavedGame) const SizedBox(width: 8),
          _buildActionButton(
            context,
            icon: Icons.edit,
            label: customGameLabel,
            onTap: widget.onCustomGame!,
          ),
        ],
      ],
    );
  }

  /// 构建紧凑布局的游戏类型卡片操作按钮
  Widget _buildCompactActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  /// 构建标准布局的游戏类型卡片操作按钮
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
