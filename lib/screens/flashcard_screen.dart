// lib/screens/flashcard_screen.dart
// Flip-card study mode. Shows Arabic → tap → reveals Russian translation.
// User marks each card as "Know" or "Again" to track progress.

import 'dart:math';
import 'package:flutter/material.dart';
import '../data/suras_data.dart';
import '../models/sura.dart';
import '../services/progress_service.dart';
import '../services/telegram_service.dart';
import '../theme/app_theme.dart';

enum FlashMode { arabicToRussian, russianToArabic }

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  final _progress = ProgressService();
  final _telegram = TelegramService();

  late List<Sura> _queue;
  int _index = 0;
  bool _isFlipped = false;
  FlashMode _mode = FlashMode.arabicToRussian;

  // AnimationController drives the 3D flip effect
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _buildQueue(shuffled: false);
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _buildQueue({bool shuffled = false, bool unknownOnly = false}) {
    List<Sura> list = unknownOnly
        ? kAllSuras.where((s) => !_progress.isMemorized(s.number)).toList()
        : List.from(kAllSuras);

    if (shuffled) list.shuffle(Random());
    setState(() {
      _queue = list;
      _index = 0;
      _isFlipped = false;
    });
    _flipCtrl.reset();
  }

  Sura get _current => _queue[_index];

  void _flip() {
    _telegram.hapticImpact('light');
    if (_isFlipped) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _answer(bool knew) {
    if (knew) {
      _telegram.hapticNotification('success');
      _progress.markMemorized(_current.number);
    } else {
      _telegram.hapticNotification('error');
    }

    if (_index < _queue.length - 1) {
      setState(() {
        _index++;
        _isFlipped = false;
      });
      _flipCtrl.reset();
    } else {
      // Round finished
      _showFinishedDialog();
    }
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Раунд завершён! 🎉', style: AppTextStyles.heading()),
        content: Text(
          'Выучено: ${_progress.memorizedCount} / 114',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _buildQueue(shuffled: true);
            },
            child: Text('Ещё раз', style: AppTextStyles.body(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Вы выучили все суры! 🎉', style: AppTextStyles.heading()),
            const SizedBox(height: 16),
            _OutlineButton(
              label: 'Повторить всё',
              onTap: () => _buildQueue(),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Top controls row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _OutlineButton(label: '🔀 Перемешать', onTap: () => _buildQueue(shuffled: true)),
              const SizedBox(width: 8),
              _OutlineButton(label: '📚 Неизвестные', onTap: () => _buildQueue(unknownOnly: true)),
              const Spacer(),
              Text(
                '${_index + 1} / ${_queue.length}',
                style: AppTextStyles.muted(),
              ),
            ],
          ),
        ),

        // Mode toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Режим:', style: AppTextStyles.muted()),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mode = _mode == FlashMode.arabicToRussian
                        ? FlashMode.russianToArabic
                        : FlashMode.arabicToRussian;
                    _isFlipped = false;
                    _flipCtrl.reset();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _mode == FlashMode.arabicToRussian
                        ? 'Арабский → Перевод'
                        : 'Перевод → Арабский',
                    style: AppTextStyles.body(size: 12, color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Flip card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _flip,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (_, __) {
                  // Show back face when animation is past halfway
                  final showBack = _flipAnim.value > 0.5;
                  final angle = _flipAnim.value * pi;

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: showBack
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _CardBack(sura: _current, mode: _mode),
                          )
                        : _CardFront(sura: _current, mode: _mode),
                  );
                },
              ),
            ),
          ),
        ),

        // Action buttons (visible only after flip)
        AnimatedOpacity(
          opacity: _isFlipped ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: '✗  Ещё раз',
                    color: AppColors.errorBg,
                    textColor: AppColors.error,
                    onTap: _isFlipped ? () => _answer(false) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: '✓  Знаю!',
                    color: AppColors.successBg,
                    textColor: AppColors.success,
                    onTap: _isFlipped ? () => _answer(true) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Sub-widgets ---

class _CardFront extends StatelessWidget {
  final Sura sura;
  final FlashMode mode;
  const _CardFront({required this.sura, required this.mode});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: AppColors.surface,
      borderColor: AppColors.gold.withOpacity(0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Сура № ${sura.number}', style: AppTextStyles.label(size: 11)),
          const SizedBox(height: 20),
          if (mode == FlashMode.arabicToRussian) ...[
            Text(sura.arabic, style: AppTextStyles.arabic(size: 48)),
            const SizedBox(height: 10),
            Text(sura.transliteration, style: AppTextStyles.muted(size: 14)),
          ] else ...[
            Text(sura.russian, style: AppTextStyles.heading(size: 26)),
          ],
          const SizedBox(height: 30),
          Text('Нажми чтобы открыть', style: AppTextStyles.muted(size: 11)),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Sura sura;
  final FlashMode mode;
  const _CardBack({required this.sura, required this.mode});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: AppColors.successBg,
      borderColor: AppColors.success.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Сура № ${sura.number}', style: AppTextStyles.label(size: 11)),
          const SizedBox(height: 20),
          if (mode == FlashMode.arabicToRussian) ...[
            Text(sura.russian, style: AppTextStyles.heading(size: 26).copyWith(color: AppColors.success)),
            const SizedBox(height: 12),
            Text(sura.arabic, style: AppTextStyles.arabic(size: 28)),
          ] else ...[
            Text(sura.arabic, style: AppTextStyles.arabic(size: 48)),
            const SizedBox(height: 10),
            Text(sura.transliteration, style: AppTextStyles.muted()),
          ],
          const SizedBox(height: 8),
          Text('${sura.verses} аятов', style: AppTextStyles.muted()),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Widget child;
  const _CardShell({required this.color, required this.borderColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.body(size: 12, color: AppColors.gold)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  const _ActionButton({required this.label, required this.color, required this.textColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(size: 14).copyWith(color: textColor),
        ),
      ),
    );
  }
}
