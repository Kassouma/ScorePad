import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class PlayerScoreCard extends StatelessWidget {
  final String name;
  final Color color;
  final int? roundScore;
  final int total;
  final bool isLeader;
  final bool isReadOnly;
  final int roundNumber;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const PlayerScoreCard({
    super.key,
    required this.name,
    required this.color,
    required this.roundScore,
    required this.total,
    required this.isLeader,
    required this.isReadOnly,
    required this.roundNumber,
    required this.onMinus,
    required this.onPlus,
  });

  String _formatScore(int? v) {
    if (v == null) return '—';
    return v >= 0 ? '+$v' : '$v';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            // Color bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Crown icon shown only for the leader
                      if (isLeader) ...[
                        const Text('👑', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.syne(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'R$roundNumber : ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        _formatScore(roundScore),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Total : ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '$total',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Score buttons
            _ScoreButton(
              label: '−',
              color: AppColors.danger,
              bgColor: const Color(0x26FF4747),
              enabled: !isReadOnly,
              onTap: onMinus,
            ),
            const SizedBox(width: 8),
            _ScoreButton(
              label: '+',
              color: AppColors.accent,
              bgColor: const Color(0x26E8FF47),
              enabled: !isReadOnly,
              onTap: onPlus,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final bool enabled;
  final VoidCallback onTap;

  const _ScoreButton({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.25,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
