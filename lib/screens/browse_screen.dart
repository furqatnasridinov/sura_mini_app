// lib/screens/browse_screen.dart
// Shows all 114 suras with search and filter (all / memorized / remaining).

import 'package:flutter/material.dart';
import '../data/suras_data.dart';
import '../models/sura.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sura_card.dart';

enum BrowseFilter { all, memorized, remaining }

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchCtrl = TextEditingController();
  BrowseFilter _filter = BrowseFilter.all;
  final _progress = ProgressService();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Sura> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return kAllSuras.where((s) {
      // Text search: matches number, arabic, transliteration, or translation
      final matchesSearch = q.isEmpty ||
          s.number.toString().contains(q) ||
          s.arabic.contains(q) ||
          s.transliteration.toLowerCase().contains(q) ||
          s.russian.toLowerCase().contains(q);

      // Filter chip
      final matchesFilter = switch (_filter) {
        BrowseFilter.all       => true,
        BrowseFilter.memorized => _progress.isMemorized(s.number),
        BrowseFilter.remaining => !_progress.isMemorized(s.number),
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final suras = _filtered;

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.body(),
            decoration: const InputDecoration(
              hintText: 'Поиск по названию или переводу...',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
            ),
          ),
        ),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _FilterChip(label: 'Все',       value: BrowseFilter.all,       selected: _filter, onTap: (f) => setState(() => _filter = f)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Выучено',   value: BrowseFilter.memorized, selected: _filter, onTap: (f) => setState(() => _filter = f)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Осталось',  value: BrowseFilter.remaining, selected: _filter, onTap: (f) => setState(() => _filter = f)),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: suras.length,
            itemBuilder: (_, i) => SuraCard(sura: suras[i]),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final BrowseFilter value;
  final BrowseFilter selected;
  final ValueChanged<BrowseFilter> onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.gold.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            color: isActive ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
