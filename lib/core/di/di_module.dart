import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sudoku/common/settings/app_settings.dart';
import 'package:sudoku/common/theme/theme_manager.dart';
import 'package:sudoku/core/index.dart';
import 'package:sudoku/games/diagonal/diagonal_game_view_model.dart';
import 'package:sudoku/games/jigsaw/jigsaw_game_view_model.dart';
import 'package:sudoku/games/killer/killer_game_view_model.dart';
import 'package:sudoku/games/standard/standard_game_view_model.dart';
import 'package:sudoku/games/window/window_game_view_model.dart';

/// 依赖注入模块
class DiModule {
  /// 所有依赖提供者
  static List<SingleChildWidget> providers = [
    // 核心服务
    Provider<BoardPool>(create: (_) => BoardPool()),
    Provider<SerializationUtils>(create: (_) => SerializationUtils()),
    Provider<GameValidator>(create: (_) => GameValidator()),
    Provider<TemplateManager>(create: (_) => TemplateManager()),
    Provider<GameGenerator>(create: (_) => GameGenerator()),
    Provider<ErrorHandler>(create: (_) => ErrorHandler()),
    
    // 设置
    ChangeNotifierProvider(create: (_) => AppSettings()..loadSettings()),
    
    // 主题管理
    ChangeNotifierProvider(create: (_) => ThemeManager()),
    
    // ViewModel
    ChangeNotifierProxyProvider<AppSettings, StandardGameViewModel>(
      create: (context) => StandardGameViewModel(context.read<AppSettings>()),
      update: (context, settings, game) => game ?? StandardGameViewModel(settings),
    ),
    ChangeNotifierProxyProvider<AppSettings, JigsawGameViewModel>(
      create: (context) => JigsawGameViewModel(context.read<AppSettings>()),
      update: (context, settings, game) => game ?? JigsawGameViewModel(settings),
    ),
    ChangeNotifierProxyProvider<AppSettings, DiagonalGameViewModel>(
      create: (context) => DiagonalGameViewModel(context.read<AppSettings>()),
      update: (context, settings, game) => game ?? DiagonalGameViewModel(settings),
    ),
    ChangeNotifierProxyProvider<AppSettings, KillerGameViewModel>(
      create: (context) => KillerGameViewModel(context.read<AppSettings>()),
      update: (context, settings, game) => game ?? KillerGameViewModel(settings),
    ),
    ChangeNotifierProxyProvider<AppSettings, WindowGameViewModel>(
      create: (context) => WindowGameViewModel(context.read<AppSettings>()),
      update: (context, settings, game) => game ?? WindowGameViewModel(settings),
    ),
  ];
}
