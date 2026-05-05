// lib/screens/quiz_screen.dart
// Multiple choice quiz: 4 options, 3 modes, tracks score + streak.

import 'dart:math';
import 'package:flutter/material.dart';
import '../data/suras_data.dart';
import '../models/sura.dart';
import '../services/telegram_service.dart';
import '../theme/app_theme.dart';

enum QuizMode { arabicToRussian, russianToArabic, numberToArabic }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _telegram = TelegramService();
  final _random = Random();

  QuizMode _mode = QuizMode.arabicToRussian;
  late Sura _correct;
  late List<Sura> _options;
  int? _selectedIndex;   // null = not answered yet
  int _score = 0;
  int _total = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    // Pick a random correct answer
    _correct = kAllSuras[_random.nextInt(114)];

    // Build 3 unique wrong options
    final wrongs = <Sura>[];
    while (wrongs.length < 3) {
      final s = kAllSuras[_random.nextInt(114)];
      if (s.number != _correct.number && !wrongs.any((w) => w.number == s.number)) {
        wrongs.add(s);
      }
    }

    // Shuffle all 4 options
    final opts = [_correct, ...wrongs]..shuffle(_random);

    setState(() {
      _options = opts;
      _selectedIndex = null;
    });
  }

  void _answer(int index) {
    if (_selectedIndex != null) return; // Already answered

    final isCorrect = _options[index].number == _correct.number;
    _total++;

    if (isCorrect) {
      _score++;
      _streak++;
      _telegram.hapticNotification('success');
    } else {
      _streak = 0;
      _telegram.hapticNotification('error');
    }

    setState(() => _selectedIndex = index);
  }

  String get _questionText {
    return switch (_mode) {
      QuizMode.arabicToRussian => 'Что означает эта сура?',
      QuizMode.russianToArabic => 'Как по-арабски называется?',
      QuizMode.numberToArabic  => 'Как называется сура № ${_correct.number}?',
    };
  }

  Widget _questionContent() {
    return switch (_mode) {
      QuizMode.arabicToRussian => Column(
          children: [
            Text(_correct.arabic, style: AppTextStyles.arabic(size: 52)),
            const SizedBox(height: 8),
            Text(_correct.transliteration, style: AppTextStyles.muted(size: 14)),
          ],
        ),
      QuizMode.russianToArabic => Column(
          children: [
            Text(_correct.russian, style: AppTextStyles.heading(size: 24)),
            const SizedBox(height: 6),
            Text('Сура № ${_correct.number}', style: AppTextStyles.muted()),
          ],
        ),
      QuizMode.numberToArabic => Text(
          '${_correct.number}',
          style: AppTextStyles.arabic(size: 64, color: AppColors.gold),
        ),
    };
  }

  String _optionLabel(Sura s) {
    return switch (_mode) {
      QuizMode.arabicToRussian => s.russian,
      QuizMode.russianToArabic => '${s.arabic}  ${s.transliteration}',
      QuizMode.numberToArabic  => '${s.arabic}  ${s.transliteration}',
    };
  }

  Color _optionBorderColor(int i) {
    if (_selectedIndex == null) return AppColors.gold.withOpacity(0.2);
    final isCorrect = _options[i].number == _correct.number;
    final isSelected = _selectedIndex == i;
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.error;
    return AppColors.gold.withOpacity(0.1);
  }

  Color _optionBgColor(int i) {
    if (_selectedIndex == null) return AppColors.surface;
    final isCorrect = _options[i].number == _correct.number;
    final isSelected = _selectedIndex == i;
    if (isCorrect) return AppColors.successBg;
    if (isSelected) return AppColors.errorBg;
    return AppColors.surface;
  }

  Color _optionTextColor(int i) {
    if (_selectedIndex == null) return AppColors.textPrimary;
    final isCorrect = _options[i].number == _correct.number;
    final isSelected = _selectedIndex == i;
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.error;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Mode selector
          _ModeSelector(current: _mode, onChanged: (m) {
            setState(() => _mode = m);
            _nextQuestion();
          }),
          const SizedBox(height: 12),

          // Score bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(label: 'Правильно', value: '$_score'),
              const SizedBox(width: 12),
              _StatChip(label: 'Всего', value: '$_total'),
              const SizedBox(width: 12),
              _StatChip(label: 'Серия 🔥', value: '$_streak'),
            ],
          ),
          const SizedBox(height: 16),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(_questionText, style: AppTextStyles.label(size: 11)),
                const SizedBox(height: 20),
                _questionContent(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options grid (2×2)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.0,
            children: List.generate(4, (i) => GestureDetector(
              onTap: () => _answer(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _optionBgColor(i),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _optionBorderColor(i)),
                ),
                child: Center(
                  child: Text(
                    _optionLabel(_options[i]),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(size: 12, color: _optionTextColor(i)),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 16),

          // Next button
          if (_selectedIndex != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Следующий →', style: AppTextStyles.heading(size: 14).copyWith(color: AppColors.background)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final QuizMode current;
  final ValueChanged<QuizMode> onChanged;
  const _ModeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final modes = [
      (QuizMode.arabicToRussian, 'Ар → Рус'),
      (QuizMode.russianToArabic, 'Рус → Ар'),
      (QuizMode.numberToArabic,  '№ → Ар'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: modes.map((entry) {
        final (mode, label) = entry;
        final active = current == mode;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.gold : AppColors.gold.withOpacity(0.3)),
              ),
              child: Text(label, style: AppTextStyles.body(size: 11, color: active ? AppColors.gold : AppColors.textMuted)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading(size: 18).copyWith(color: AppColors.gold)),
        Text(label, style: AppTextStyles.muted(size: 10)),
      ],
    );
  }
}
