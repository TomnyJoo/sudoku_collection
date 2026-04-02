import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

/// 本地化工具类
class LocalizationUtils {
  /// 获取当前语言环境的翻译
  static AppLocalizations? of(final BuildContext context) => AppLocalizations.of(context);

  /// 获取当前语言代码
  static String getCurrentLocaleCode(final BuildContext context) => Localizations.localeOf(context).languageCode;

  /// 获取支持的语言列表
  static List<Locale> get supportedLocales => const [
        Locale('en', 'US'), // 英语
        Locale('zh', 'CN'), // 中文简体
      ];

  /// 获取本地化代理
  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}
