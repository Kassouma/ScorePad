import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class CoffeeButton extends StatelessWidget {
  const CoffeeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () => launchUrl(
            Uri.parse('https://buymeacoffee.com/kassoum'),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Text('☕', style: TextStyle(fontSize: 14)),
          label: Text(
            'Buy the dev a coffee',
            style: GoogleFonts.syne(fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
