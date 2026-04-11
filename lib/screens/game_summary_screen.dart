import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class GameSummaryScreen extends StatelessWidget {
  final GameState state;

  const GameSummaryScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final totals = state.totals;
    final ranked = <_Ranked>[];
    for (var i = 0; i < state.players.length; i++) {
      ranked.add(_Ranked(player: state.players[i], total: totals[i], index: i));
    }
    ranked.sort((a, b) => b.total.compareTo(a.total));

    final roundCount = state.liveRound + 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                children: [
                  const Text('🏁', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 10),
                  Text(
                    'GAME OVER',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syne(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$roundCount round${roundCount > 1 ? 's' : ''} played',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Podium ────────────────────────────────────────────────
            _Podium(ranked: ranked),

            const SizedBox(height: 24),

            // ── Round breakdown ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ROUND BREAKDOWN',
                style: GoogleFonts.syne(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _RoundTable(state: state, ranked: ranked),
            ),
            const SizedBox(height: 12),

            // ── New game button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GestureDetector(
                onTap: () async {
                  final provider = context.read<GameProvider>();
                  await provider.backToSetup();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'New game →',
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal data model ──────────────────────────────────────────────────────

class _Ranked {
  final Player player;
  final int total;
  final int index; // original index in state.players

  const _Ranked({required this.player, required this.total, required this.index});
}

// ── Podium ───────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<_Ranked> ranked;

  const _Podium({required this.ranked});

  @override
  Widget build(BuildContext context) {
    // Classic podium display order: 2nd | 1st | 3rd
    final slots = <({_Ranked entry, int rank, double height, String medal})>[];
    if (ranked.length >= 2) {
      slots.add((entry: ranked[1], rank: 2, height: 64, medal: '🥈'));
    }
    slots.add((entry: ranked[0], rank: 1, height: 96, medal: '🥇'));
    if (ranked.length >= 3) {
      slots.add((entry: ranked[2], rank: 3, height: 44, medal: '🥉'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: slots
            .map((slot) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _PodiumSlot(
                      player: slot.entry.player,
                      total: slot.entry.total,
                      rank: slot.rank,
                      podiumHeight: slot.height,
                      medal: slot.medal,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final Player player;
  final int total;
  final int rank;
  final double podiumHeight;
  final String medal;

  const _PodiumSlot({
    required this.player,
    required this.total,
    required this.rank,
    required this.podiumHeight,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = rank == 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: TextStyle(fontSize: isWinner ? 32 : 24)),
        const SizedBox(height: 6),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: player.color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: GoogleFonts.syne(
            fontSize: isWinner ? 15 : 12,
            fontWeight: FontWeight.w700,
            color: isWinner ? AppColors.accent : AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          '$total pts',
          style: GoogleFonts.jetBrainsMono(
            fontSize: isWinner ? 18 : 13,
            fontWeight: FontWeight.w700,
            color: isWinner ? AppColors.accent : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        // Podium block
        Container(
          height: podiumHeight,
          decoration: BoxDecoration(
            color: isWinner
                ? const Color(0x1FE8FF47) // accent at ~12% opacity
                : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(
              color: isWinner ? AppColors.accent : AppColors.border,
              width: isWinner ? 2 : 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: GoogleFonts.syne(
              fontSize: isWinner ? 22 : 16,
              fontWeight: FontWeight.w800,
              color: isWinner ? AppColors.accent : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Round breakdown table ────────────────────────────────────────────────────

class _RoundTable extends StatelessWidget {
  final GameState state;
  final List<_Ranked> ranked;

  const _RoundTable({required this.state, required this.ranked});

  @override
  Widget build(BuildContext context) {
    final totalRounds = state.liveRound + 1;
    const rowHeight = 38.0;
    const colWidth = 72.0;
    const labelWidth = 40.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // ── Column headers: player names ─────────────────────
                  Container(
                    color: AppColors.surface2,
                    child: Row(
                      children: [
                        SizedBox(width: labelWidth, height: rowHeight),
                        for (final r in ranked)
                          SizedBox(
                            width: colWidth,
                            height: rowHeight,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: r.player.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.player.name,
                                    style: GoogleFonts.syne(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppColors.border),

                  // ── One row per round ────────────────────────────────
                  for (var round = 0; round < totalRounds; round++)
                    Container(
                      color: round.isOdd ? AppColors.surface2 : AppColors.surface,
                      child: Row(
                        children: [
                          SizedBox(
                            width: labelWidth,
                            height: rowHeight,
                            child: Center(
                              child: Text(
                                'R${round + 1}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          for (final r in ranked)
                            SizedBox(
                              width: colWidth,
                              height: rowHeight,
                              child: Center(
                                child: Text(
                                  _fmt(state.rounds[round][r.index]),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  Container(height: 1, color: AppColors.border),

                  // ── Totals row ───────────────────────────────────────
                  Container(
                    color: AppColors.surface2,
                    child: Row(
                      children: [
                        SizedBox(
                          width: labelWidth,
                          height: rowHeight,
                          child: Center(
                            child: Text(
                              'TOT',
                              style: GoogleFonts.syne(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        for (var i = 0; i < ranked.length; i++)
                          SizedBox(
                            width: colWidth,
                            height: rowHeight,
                            child: Center(
                              child: Text(
                                '${ranked[i].total}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  // Highlight the winner's total
                                  color: i == 0
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(int? v) {
    if (v == null) return '—';
    return v >= 0 ? '+$v' : '$v';
  }
}
