// lib/screens/progress_screen.dart
// Visual progress overview: stats, progress bar, and 114 dot grid.

import 'package:flutter/material.dart';
import '../data/suras_data.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _progress = ProgressService();

  void _toggleDot(int surahNumber) {
    setState(() {
      _progress.toggle(surahNumber);
    });
  }

  void _resetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Сбросить прогресс?', style: AppTextStyles.heading()),
        content: Text('Все отметки будут удалены.', style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Отмена', style: AppTextStyles.body(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Сбросить', style: AppTextStyles.body(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _progress.reset();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final memorized = _progress.memorizedCount;
    final remaining = 114 - memorized;
    final percent = memorized / 114;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Выучено',  value: '$memorized', color: AppColors.success)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Осталось', value: '$remaining', color: AppColors.gold)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Прогресс', value: '${(percent * 100).round()}%', color: AppColors.goldLight)),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Нажми на кружок чтобы отметить выученным',
            style: AppTextStyles.muted(size: 11),
          ),
          const SizedBox(height: 12),

          // 114 dot grid
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kAllSuras.map((s) {
              final mem = _progress.isMemorized(s.number);
              return GestureDetector(
                onTap: () => _toggleDot(s.number),
                child: Tooltip(
                  message: '${s.number}. ${s.transliteration}',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mem ? AppColors.success.withOpacity(0.2) : AppColors.surfaceAlt,
                      border: Border.all(
                        color: mem ? AppColors.success : AppColors.gold.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${s.number}',
                        style: AppTextStyles.body(
                          size: 9,
                          color: mem ? AppColors.success : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Reset button
          Center(
            child: TextButton(
              onPressed: _resetAll,
              child: Text('Сбросить прогресс', style: AppTextStyles.body(size: 13, color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading(size: 24).copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.muted(size: 10)),
        ],
      ),
    );
  }
}
