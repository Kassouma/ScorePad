import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coffee_button.dart';
import '../widgets/player_setup_row.dart';
import 'game_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, provider, _) {
            final players = provider.setupPlayers;
            final canStart = players.length >= 2;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Column(
                    children: [
                      Text(
                        'ScorePad',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.syne(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'UNIVERSAL SCORE COUNTER',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Section label
                  Text(
                    'PLAYERS',
                    style: GoogleFonts.syne(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Reorderable player list
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: players.length,
                      onReorder: provider.reorderSetupPlayer,
                      proxyDecorator: (child, _, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (_, _) => Material(
                            color: Colors.transparent,
                            child: child,
                          ),
                        );
                      },
                      itemBuilder: (context, i) {
                        final p = players[i];
                        return Padding(
                          key: ValueKey(i),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PlayerSetupRow(
                            index: i,
                            name: p.name,
                            color: p.color,
                            canRemove: players.length > 2,
                            onNameChanged: (v) =>
                                provider.renameSetupPlayer(i, v),
                            onRemove: () => provider.removeSetupPlayer(i),
                          ),
                        );
                      },
                      footer: players.length < 8
                          ? Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: _AddPlayerButton(
                                onTap: () => provider.addSetupPlayer(),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Start button
                  _StartButton(
                    enabled: canStart,
                    onTap: () async {
                      await provider.startGame();
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const CoffeeButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddPlayerButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPlayerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+ Add player',
              style: GoogleFonts.syne(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _StartButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled ? AppColors.accent : AppColors.border,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Start game →',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: enabled ? Colors.black : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
