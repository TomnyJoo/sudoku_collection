import 'package:sudoku/core/models/difficulty.dart';
import 'package:sudoku/core/models/region.dart';

/// 数独游戏类型枚举，定义不同类型的数独游戏
enum GameType {
  standard,    // 标准数独（9x9宫格）
  jigsaw,      // 锯齿数独（不规则区域）
  diagonal,    // 对角线数独
  window,      // 窗口数独
  killer,      // 杀手数独
  samurai,     // 武士数独
  custom,      // 自定义数独
}

/// 游戏类型配置，包含每种游戏类型的具体配置参数
class GameTypeConfig {  /// 描述信息国际化键

  /// 构造游戏类型配置
  const GameTypeConfig({
    required this.type,
    required this.nameKey,
    required this.boardSize,
    required this.supportedRegionTypes,
    required this.supportsCustomRules,
    required this.supportsDifficulty,
    required this.iconPath,
    required this.descriptionKey,
  });
  
  final GameType type;  /// 游戏类型
  final String nameKey;  /// 名称国际化键
  final int boardSize;  /// 棋盘尺寸（通常为9）
  final List<RegionType> supportedRegionTypes;  /// 支持的区域类型
  final bool supportsCustomRules;  /// 是否支持自定义规则
  final bool supportsDifficulty;  /// 是否支持难度选择
  final String iconPath;  /// 图标资源路径
  final String descriptionKey;

  /// 获取本地化的名称
  String getLocalizedName(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations[nameKey] ?? nameKey;
      }
    } catch (e) {
      // 忽略异常
    }
    return nameKey;
  }

  /// 获取本地化的描述信息
  String getLocalizedDescription(final dynamic localizations) {
    try {
      if (localizations is Map) {
        return localizations[descriptionKey] ?? descriptionKey;
      }
    } catch (e) {
      // 忽略异常
    }
    return descriptionKey;
  }

  /// 检查是否支持指定区域类型
  bool supportsRegionType(final RegionType regionType) =>
    supportedRegionTypes.contains(regionType);

  /// 检查是否有效游戏类型配置
  bool get isValid =>
    boardSize > 0 &&
    supportedRegionTypes.isNotEmpty;

  /// 获取支持的难度级别
  List<Difficulty> getSupportedDifficulties() {
    if (!supportsDifficulty) return [];
    
    return Difficulty.values.where((final difficulty) =>
      difficulty != Difficulty.custom
    ).toList();
  }

  /// 获取用于调试的字符串表示（不依赖国际化）
  String toDebugString() => 'GameTypeConfig(type: $type, nameKey: $nameKey, boardSize: $boardSize)';

  /// 获取用于显示的字符串表示（考虑国际化）
  String toDisplayString({final dynamic localizations}) {
    // 使用本地化字符串或默认值
    final gameName = getLocalizedName(localizations);
    final difficultyStr = _getLocalizedDifficultyStr(localizations);
    final customStr = _getLocalizedCustomRulesStr(localizations);
    final regionTypesStr = _getLocalizedRegionTypesStr(localizations);
    final boardSizeStr = _getLocalizedBoardSizeStr(localizations);
    
    return '$gameName - $boardSizeStr, $difficultyStr, $customStr, $regionTypesStr';
  }

  /// 获取本地化的难度选择文本
  String _getLocalizedDifficultyStr(final dynamic localizations) {
    try {
      if (localizations is Map) {
        if (supportsDifficulty) {
          return localizations['supportsDifficulty'] ?? '支持难度选择';
        } else {
          return localizations['fixedDifficulty'] ?? '固定难度';
        }
      }
    } catch (e) {
      // 忽略异常
    }
    return supportsDifficulty ? '支持难度选择' : '固定难度';
  }

  /// 获取本地化的自定义规则文本
  String _getLocalizedCustomRulesStr(final dynamic localizations) {
    try {
      if (localizations is Map) {
        if (supportsCustomRules) {
          return localizations['supportsCustomRules'] ?? '支持自定义规则';
        } else {
          return localizations['standardRules'] ?? '标准规则';
        }
      }
    } catch (e) {
      // 忽略异常
    }
    return supportsCustomRules ? '支持自定义规则' : '标准规则';
  }

  /// 获取本地化的区域类型文本
  String _getLocalizedRegionTypesStr(final dynamic localizations) {
    final regionTypesStr = supportedRegionTypes.map((final type) => 
      _getRegionTypeDisplayName(type, localizations)).join('、');
    
    try {
      if (localizations is Map) {
        final regionTypesLabel = localizations['regionTypes'] ?? '区域类型';
        return '$regionTypesLabel: $regionTypesStr';
      }
    } catch (e) {
      // 忽略异常
    }
    return '区域类型: $regionTypesStr';
  }

  /// 获取本地化的棋盘尺寸文本
  String _getLocalizedBoardSizeStr(final dynamic localizations) {
    try {
      if (localizations is Map) {
        final boardSizeLabel = localizations['boardSize'] ?? '棋盘';
        return '$boardSizeLabel: $boardSize×$boardSize';
      }
    } catch (e) {
      // 忽略异常
    }
    return '$boardSize×$boardSize棋盘';
  }

  /// 获取区域类型的显示名称
  String _getRegionTypeDisplayName(final RegionType type, final dynamic localizations) {
    try {
      if (localizations is Map) {
        switch (type) {
          case RegionType.block:
            return localizations['blockRegion'] ?? '宫格';
          case RegionType.row:
            return localizations['rowRegion'] ?? '行';
          case RegionType.column:
            return localizations['columnRegion'] ?? '列';
          case RegionType.diagonal:
            return localizations['diagonalRegion'] ?? '对角线';
          case RegionType.window:
            return localizations['windowRegion'] ?? '窗口';
          case RegionType.jigsaw:
            return localizations['jigsawRegion'] ?? '锯齿';
          case RegionType.cage:
            return localizations['cageRegion'] ?? '笼子';
          case RegionType.custom:
            return localizations['customRegion'] ?? '自定义';
        }
      }
    } catch (e) {
      // 忽略异常
    }
    return type.toString().split('.').last;
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is GameTypeConfig && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => toDebugString();
}

/// 游戏类型配置工厂类，负责管理所有游戏类型的配置数据
class GameTypeConfigFactory {
  /// 游戏类型配置映射
  static const Map<GameType, GameTypeConfig> _configs = {
    GameType.standard: GameTypeConfig(
          type: GameType.standard,
          nameKey: 'gameTypeStandardName',
          boardSize: 9,
          supportedRegionTypes: [RegionType.block],
          supportsCustomRules: false,
          supportsDifficulty: true,
          iconPath: 'assets/icons/standard.png',
          descriptionKey: 'gameTypeStandardDescription',
        ),
    GameType.samurai: GameTypeConfig(
          type: GameType.samurai,
          nameKey: 'gameTypeSamuraiName',
          boardSize: 21,
          supportedRegionTypes: [RegionType.block],
          supportsCustomRules: false,
          supportsDifficulty: true,
          iconPath: 'assets/icons/samurai.png',
          descriptionKey: 'gameTypeSamuraiDescription',
        ),
    GameType.jigsaw: GameTypeConfig(
      type: GameType.jigsaw,
      nameKey: 'gameTypeJigsawName',
      boardSize: 9,
      supportedRegionTypes: [RegionType.jigsaw],
      supportsCustomRules: true,
      supportsDifficulty: true,
      iconPath: 'assets/icons/jigsaw.png',
      descriptionKey: 'gameTypeJigsawDescription',
    ),
    GameType.diagonal: GameTypeConfig(
      type: GameType.diagonal,
      nameKey: 'gameTypeDiagonalName',
      boardSize: 9,
      supportedRegionTypes: [RegionType.block, RegionType.diagonal],
      supportsCustomRules: false,
      supportsDifficulty: true,
      iconPath: 'assets/icons/diagonal.png',
      descriptionKey: 'gameTypeDiagonalDescription',
    ),
    GameType.window: GameTypeConfig(
      type: GameType.window,
      nameKey: 'gameTypeWindowName',
      boardSize: 9,
      supportedRegionTypes: [RegionType.block, RegionType.window],
      supportsCustomRules: false,
      supportsDifficulty: true,
      iconPath: 'assets/icons/window.png',
      descriptionKey: 'gameTypeWindowDescription',
    ),
    GameType.killer: GameTypeConfig(
      type: GameType.killer,
      nameKey: 'gameTypeKillerName',
      boardSize: 9,
      supportedRegionTypes: [RegionType.block],
      supportsCustomRules: false,
      supportsDifficulty: true,
      iconPath: 'assets/icons/killer.png',
      descriptionKey: 'gameTypeKillerDescription',
    ),

    GameType.custom: GameTypeConfig(
      type: GameType.custom,
      nameKey: 'gameTypeCustomName',
      boardSize: 9,
      supportedRegionTypes: RegionType.values,
      supportsCustomRules: true,
      supportsDifficulty: false,
      iconPath: 'assets/icons/custom.png',
      descriptionKey: 'gameTypeCustomDescription',
    ),
  };

  /// 获取指定游戏类型的配置
  static GameTypeConfig getConfig(final GameType type) {
    final config = _configs[type];
    if (config == null) {
      final errorMsg = '未知的游戏类型: $type';
      throw ArgumentError(errorMsg);
    }
    return config;
  }

  /// 获取所有游戏类型配置
  static List<GameTypeConfig> getAllConfigs() => _configs.values.toList();

  /// 根据本地化名称获取配置
  static GameTypeConfig getConfigByName(final String name, {final dynamic localizations}) {
    for (final config in _configs.values) {
      if (config.getLocalizedName(localizations) == name) {
        return config;
      }
    }
    
    final errorMsg = '未知的游戏类型名称: $name';
    throw ArgumentError(errorMsg);
  }

  /// 检查游戏类型是否存在
  static bool exists(final GameType type) => _configs.containsKey(type);

  /// 获取支持的游戏类型列表
  static List<GameType> getSupportedTypes() => _configs.keys.toList();

  /// 获取配置数量
  static int getConfigCount() => _configs.length;

  /// 获取用于调试的字符串表示
  static String toDebugString() => 'GameTypeConfigFactory(configs: ${_configs.length})';
}

/// GameType枚举扩展方法
extension GameTypeExtension on GameType {
  /// 获取游戏类型配置
  GameTypeConfig get config => GameTypeConfigFactory.getConfig(this);
  
  /// 检查配置是否存在
  bool get hasConfig => GameTypeConfigFactory.exists(this);
  
  /// 获取本地化名称
  String getLocalizedName(final dynamic localizations) => 
    config.getLocalizedName(localizations);
  
  /// 获取本地化描述
  String getLocalizedDescription(final dynamic localizations) => 
    config.getLocalizedDescription(localizations);
  
  /// 获取显示字符串
  String toDisplayString({final dynamic localizations}) => 
    config.toDisplayString(localizations: localizations);
}
