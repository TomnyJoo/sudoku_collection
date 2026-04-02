import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/app_initializer.dart';
import 'package:sudoku/common/index.dart';
import 'package:sudoku/core/di/di_module.dart';
import 'package:sudoku/games/diagonal/index.dart';
import 'package:sudoku/games/jigsaw/index.dart';
import 'package:sudoku/games/killer/index.dart';
import 'package:sudoku/games/samurai/index.dart';
import 'package:sudoku/games/standard/index.dart';
import 'package:sudoku/games/window/index.dart';

void main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.error(
          'Flutter Framework Error',
          details.exception,
          details.stack,
        );
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(details);
        }
      };

      final initializationSuccess = await AppInitializer.initialize();

      if (!initializationSuccess) {
        runApp(const ErrorApp());
        return;
      }

      runApp(
        MultiProvider(providers: DiModule.providers, child: const SudokuApp()),
      );
    },
    (Object error, StackTrace stackTrace) {
      AppLogger.error('Uncaught async error', error, stackTrace);
      if (kDebugMode) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    },
  );
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('App initialization failed'),
            SizedBox(height: 8),
            TextButton(onPressed: main, child: Text('Retry')),
          ],
        ),
      ),
    ),
  );
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettings>(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final locale = appSettings.language == 'zh'
        ? const Locale('zh', 'CN')
        : const Locale('en', 'US');

    return MaterialApp(
      title: LocalizationUtils.of(context)?.appName ?? 'Sudoku',
      theme: themeManager.getTheme(context),
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      locale: locale,
      localizationsDelegates: LocalizationUtils.localizationDelegates,
      supportedLocales: LocalizationUtils.supportedLocales,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/standard_game': (context) => const StandardGameScreenWrapper(),
        '/standard_custom': (context) => const StandardCustomGameScreenWrapper(),
        '/jigsaw_game': (context) => const JigsawGameScreenWrapper(),
        '/diagonal_game': (context) => const DiagonalGameScreenWrapper(),
        '/diagonal_custom': (
            context) => const DiagonalCustomGameScreenWrapper(),
        '/killer_game': (context) => const KillerGameScreenWrapper(),
        '/window_game': (context) => const WindowGameScreenWrapper(),
        '/samurai_game': (context) => const SamuraiGameScreenWrapper(),
        '/statistics': (context) => const GameStatisticsScreen(),
        '/settings': (context) => const SettingsScreenWrapper(),
      },
    );
  }
}

class StandardGameScreenWrapper extends StatelessWidget {
  const StandardGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: context.read<StandardGameViewModel>(),
    child: const StandardGameScreen(),
  );
}

class JigsawGameScreenWrapper extends StatelessWidget {
  const JigsawGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: context.read<JigsawGameViewModel>(),
      child: const JigsawGameScreen(),
    );
}

class DiagonalGameScreenWrapper extends StatelessWidget {
  const DiagonalGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: context.read<DiagonalGameViewModel>(),
      child: const DiagonalGameScreen(),
    );
}

class DiagonalCustomGameScreenWrapper extends StatelessWidget {
  const DiagonalCustomGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: context.read<DiagonalGameViewModel>(),
      child: const DiagonalCustomGameScreen(),
    );
}

class KillerGameScreenWrapper extends StatelessWidget {
  const KillerGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: context.read<KillerGameViewModel>(),
      child: const KillerGameScreen(),
    );
}

class WindowGameScreenWrapper extends StatelessWidget {
  const WindowGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: context.read<WindowGameViewModel>(),
      child: const WindowGameScreen(),
    );
}

class SamuraiGameScreenWrapper extends StatelessWidget {

  const SamuraiGameScreenWrapper({
    super.key,
    this.initialState,
    this.gameState,
  });
  final SamuraiGameState? initialState;
  final SamuraiGameState? gameState;

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: context.read<AppSettings>()),
        ChangeNotifierProvider(
          create: (context) {
            if (gameState != null) {
              return SamuraiGameViewModel.withState(gameState!);
            }
            return SamuraiGameViewModel();
          },
        ),
      ],
      child: const SamuraiGameScreen(),
    );
}

class StandardCustomGameScreenWrapper extends StatelessWidget {
  const StandardCustomGameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) => const StandardCustomGameScreen();
}
