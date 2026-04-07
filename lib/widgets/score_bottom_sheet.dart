import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class ScoreBottomSheet extends StatefulWidget {
  final String playerName;
  final Color playerColor;
  final int sign; // +1 or -1

  const ScoreBottomSheet({
    super.key,
    required this.playerName,
    required this.playerColor,
    required this.sign,
  });

  @override
  State<ScoreBottomSheet> createState() => _ScoreBottomSheetState();
}

class _ScoreBottomSheetState extends State<ScoreBottomSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _isPlus => widget.sign > 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirm() {
    final val = int.tryParse(_controller.text);
    if (val == null || val < 0) return;
    Navigator.of(context).pop(val);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
          left: BorderSide(color: AppColors.border, width: 1.5),
          right: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 28, 20, 36 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.playerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.playerName,
                style: GoogleFonts.syne(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                _isPlus ? 'ADD' : 'SUBTRACT',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Number input
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 16,
                child: Text(
                  _isPlus ? '+' : '−',
                  style: GoogleFonts.syne(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _isPlus ? AppColors.accent : AppColors.danger,
                    height: 1,
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _confirm(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 32,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.surface2,
                  contentPadding:
                      const EdgeInsets.fromLTRB(48, 16, 16, 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.bg,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.syne(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPlus ? AppColors.accent : AppColors.danger,
                    foregroundColor: _isPlus ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isPlus ? 'Add' : 'Subtract',
                    style: GoogleFonts.syne(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Opens the score bottom sheet and returns the entered value (or null).
Future<int?> showScoreBottomSheet(
  BuildContext context, {
  required String playerName,
  required Color playerColor,
  required int sign,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ScoreBottomSheet(
      playerName: playerName,
      playerColor: playerColor,
      sign: sign,
    ),
  );
}
