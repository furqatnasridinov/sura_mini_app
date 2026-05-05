// lib/widgets/sura_card.dart
// A single card in the Browse tab list.
// Shows: number, arabic name, transliteration, translation, verse count.
// Tapping toggles memorized state.

import 'package:flutter/material.dart';
import '../models/sura.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class SuraCard extends StatefulWidget {
  final Sura sura;

  const SuraCard({super.key, required this.sura});

  @override
  State<SuraCard> createState() => _SuraCardState();
}

class _SuraCardState extends State<SuraCard> {
  final _progress = ProgressService();

  void _toggle() {
    setState(() {
      _progress.toggle(widget.sura.number);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMemorized = _progress.isMemorized(widget.sura.number);

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          
        ),
        child: Row(
          children: [
            // Number badge
            _NumberBadge(number: widget.sura.number),
            const SizedBox(width: 14),

            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sura.arabic, style: AppTextStyles.arabic(size: 20)),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.sura.transliteration} · ${widget.sura.russian}',
                    style: AppTextStyles.muted(size: 12),
                  ),
                ],
              ),
            ),

            // Verses + checkmark
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMemorized)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(height: 4),
                Text('${widget.sura.verses} аят.', style: AppTextStyles.muted(size: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withOpacity(0.1),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          '$number',
          style: AppTextStyles.body(size: 11, color: AppColors.gold),
        ),
      ),
    );
  }
}
