// lib/main.dart
// App entry point. Initializes services and sets up navigation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/progress_service.dart';
import 'services/telegram_service.dart';
import 'theme/app_theme.dart';
import 'screens/browse_screen.dart';
import 'screens/flashcard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load memorized suras from localStorage before showing UI
  await ProgressService().init();

  // Initialize Telegram Mini App (no-op when running in browser)
  final tg = TelegramService();
  tg.expand();  // Full screen height in Telegram
  tg.ready();   // Tell Telegram we're ready to display

  // Lock to portrait on mobile
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const QuranSurasApp());
}

class QuranSurasApp extends StatelessWidget {
  const QuranSurasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '114 Сур Корана',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const _HomeShell(),
    );
  }
}

// Bottom navigation shell — wraps all 4 screens
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 0;

  static const _screens = [
    BrowseScreen(),
    FlashcardScreen(),
    QuizScreen(),
    ProgressScreen(),
  ];

  static const _labels = ['Суры', 'Карточки', 'Тест', 'Прогресс'];

  static const _icons = [
    Icons.menu_book_outlined,
    Icons.style_outlined,
    Icons.quiz_outlined,
    Icons.bar_chart_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom header
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'سور القرآن الكريم',
              style: AppTextStyles.arabic(size: 20, color: AppColors.gold),
            ),
            Text('114 Сур Священного Корана', style: AppTextStyles.muted(size: 10)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.gold.withOpacity(0.2)),
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        // IndexedStack keeps all screens alive (preserves state when switching tabs)
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: List.generate(4, (i) => BottomNavigationBarItem(
          icon: Icon(_icons[i]),
          label: _labels[i],
        )),
      ),
    );
  }
}
