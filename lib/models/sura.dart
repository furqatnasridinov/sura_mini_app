// lib/models/sura.dart
// Data model representing a single Quran surah

class Sura {
  final int number;
  final String arabic;        // Arabic name
  final String transliteration; // Latin transliteration (e.g. "Al-Fatiha")
  final String russian;       // Russian translation of the name
  final int verses;           // Number of ayahs

  const Sura({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.russian,
    required this.verses,
  });
}
