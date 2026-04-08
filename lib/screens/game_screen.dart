import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coffee_button.dart';
import '../widgets/player_score_card.dart';
import '../widgets/reset_bottom_sheet.dart';
import '../widgets/score_bottom_sheet.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, provider, _) {
            final state = provider.state;
            if (state == null) {
              return const SizedBox.shrink();
            }

            final isLive = state.isViewingLive;
            final roundScores = state.rounds[state.currentRound];
            final totals = state.totals;
            final maxTotal = totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);

            return Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'ScorePad',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      _IconBtn(
                        icon: '↺',
                        onTap: () async {
                          final confirmed =
                              await showResetBottomSheet(context);
                          if (confirmed && context.mounted) {
                            await provider.resetScores();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _IconBtn(
                        icon: '⊞',
                        onTap: () async {
                          await provider.backToSetup();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // ── Round navigation ──────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      _NavBtn(
                        label: '‹',
                        enabled: state.currentRound > 0,
                        onTap: () =>
                            provider.goToRound(state.currentRound - 1),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'ROUND',
                              style: GoogleFonts.syne(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              '${state.currentRound + 1}',
                              style: GoogleFonts.syne(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            if (!isLive)
                              Text(
                                'read-only',
                                style: GoogleFonts.syne(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _NavBtn(
                        label: '›',
                        enabled: state.currentRound < state.liveRound,
                        onTap: () =>
                            provider.goToRound(state.currentRound + 1),
                      ),
                    ],
                  ),
                ),

                // ── Player cards ──────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: state.players.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final player = state.players[i];
                      final total = totals[i];
                      final isLeader =
                          total == maxTotal && maxTotal != 0;

                      return PlayerScoreCard(
                        name: player.name,
                        color: player.color,
                        roundScore: roundScores[i],
                        total: total,
                        isLeader: isLeader,
                        isReadOnly: !isLive,
                        roundNumber: state.currentRound + 1,
                        onMinus: () => _openScoreSheet(
                            context, provider, state, i, -1),
                        onPlus: () => _openScoreSheet(
                            context, provider, state, i, 1),
                      );
                    },
                  ),
                ),

                // ── Next round / back-to-live button ──────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: _NextRoundButton(
                    isLive: isLive,
                    allFilled: state.currentRoundComplete,
                    liveRound: state.liveRound,
                    onNextRound: () => provider.nextRound(),
                    onBackToLive: () => provider.goToLive(),
                  ),
                ),

                // ── Coffee button ─────────────────────────────────────────
                const CoffeeButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openScoreSheet(
    BuildContext context,
    GameProvider provider,
    GameState state,
    int playerIndex,
    int sign,
  ) async {
    final player = state.players[playerIndex];
    final value = await showScoreBottomSheet(
      context,
      playerName: player.name,
      playerColor: player.color,
      sign: sign,
    );
    if (value != null && context.mounted) {
      await provider.enterScore(playerIndex, sign, value);
    }
  }
}

// ── Small helper widgets ───────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          icon,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.2,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.syne(
              fontSize: 24,
              color: AppColors.textMuted,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _NextRoundButton extends StatelessWidget {
  final bool isLive;
  final bool allFilled;
  final int liveRound;
  final VoidCallback onNextRound;
  final VoidCallback onBackToLive;

  const _NextRoundButton({
    required this.isLive,
    required this.allFilled,
    required this.liveRound,
    required this.onNextRound,
    required this.onBackToLive,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLive) {
      return GestureDetector(
        onTap: onBackToLive,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '← Back to round ${liveRound + 1}',
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: allFilled ? onNextRound : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: allFilled ? AppColors.accent : AppColors.border,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Next round →',
          style: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: allFilled ? Colors.black : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
