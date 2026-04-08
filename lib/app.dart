import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'screens/game_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

class ScorePadApp extends StatelessWidget {
  const ScorePadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..init(),
      child: MaterialApp(
        title: 'ScorePad',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _resumeHandled = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<GameProvider, bool>((p) => p.loading);
    final hasGame = context.select<GameProvider, bool>((p) => p.state != null);

    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    // Auto-navigate only once: when initial load completes with a persisted game.
    // Never react to hasGame changing afterwards (e.g. after startGame()).
    if (!_resumeHandled) {
      _resumeHandled = true;
      if (hasGame) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          }
        });
      }
    }

    return const SetupScreen();
  }
}
