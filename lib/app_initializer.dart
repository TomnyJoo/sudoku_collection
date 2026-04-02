import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/common/utils/app_logger.dart';
import 'package:sudoku/core/processors/template_manager.dart';

enum InitializationStatus {
  uninitialized,
  initializing,
  completed,
  failed
}

class AppInitializer {
  static InitializationStatus _status = InitializationStatus.uninitialized;
  static InitializationStatus get status => _status;
  
  static Future<bool> initialize() async {
    _status = InitializationStatus.initializing;
    final stopwatch = Stopwatch()..start();
    
    try {
      await _initializeBaseServices();
      await _preloadResources();
      await _preloadTemplates();
      
      _status = InitializationStatus.completed;
      stopwatch.stop();
      return true;
    } catch (e) {
      _status = InitializationStatus.failed;
      return false;
    }
  }
  
  static Future<void> _initializeBaseServices() async {
    // 确保 ServicesBinding 已初始化
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance();
  }
  
  static Future<void> _preloadResources() async {
    final resources = [
      'assets/images/sudoku.svg',
      'assets/images/sudoku.png',
    ];
    
    await Future.wait(
      resources.map((path) => rootBundle.load(path).catchError((e) {
        AppLogger.warning('Failed to preload resource: $path');
        return ByteData(0);
      })),
    );
  }
  
  static Future<void> _preloadTemplates() async {
    final templateManager = TemplateManager();
    await templateManager.initialize();
  }
}
