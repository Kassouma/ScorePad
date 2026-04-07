import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class PlayerSetupRow extends StatelessWidget {
  final String name;
  final Color color;
  final bool canRemove;
  final int index;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onRemove;

  const PlayerSetupRow({
    super.key,
    required this.name,
    required this.color,
    required this.canRemove,
    required this.index,
    required this.onNameChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Icon(
                Icons.drag_indicator,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          // Name input
          Expanded(
            child: TextFormField(
              initialValue: name,
              onChanged: onNameChanged,
              style: GoogleFonts.syne(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Player ${index + 1}',
                hintStyle: GoogleFonts.syne(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLength: 20,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
            ),
          ),
          // Remove button
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              color: AppColors.textMuted,
              iconSize: 20,
              splashRadius: 18,
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
