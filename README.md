# 114 Сур Корана — Flutter Telegram Mini App

## Структура проекта

```
lib/
├── main.dart                  # Точка входа, навигация
├── models/
│   └── sura.dart              # Модель данных суры
├── data/
│   └── suras_data.dart        # Все 114 сур
├── theme/
│   └── app_theme.dart         # Цвета, стили текста
├── services/
│   ├── progress_service.dart  # Сохранение прогресса (localStorage)
│   └── telegram_service.dart  # JS interop с Telegram WebApp SDK
├── screens/
│   ├── browse_screen.dart     # Список всех сур с поиском
│   ├── flashcard_screen.dart  # Флеш-карточки с анимацией переворота
│   ├── quiz_screen.dart       # Тест с 4 вариантами
│   └── progress_screen.dart   # Визуальный прогресс
└── widgets/
    └── sura_card.dart         # Карточка суры для Browse

web/
└── index.html                 # Подключает Telegram WebApp JS SDK
```

---

## Шаг 1 — Установить Flutter

```bash
# Скачать Flutter SDK с flutter.dev
# Проверить установку:
flutter doctor

# Убедиться что web включён:
flutter config --enable-web
flutter devices  # должен показать Chrome
```

---

## Шаг 2 — Установить зависимости

```bash
cd quran_suras
flutter pub get
```

---

## Шаг 3 — Запустить локально (для разработки)

```bash
flutter run -d chrome
```

Приложение откроется в Chrome. TelegramService будет молча игнорировать вызовы вне Telegram — всё работает нормально.

---

## Шаг 4 — Собрать продакшн билд

```bash
flutter build web --release --base-href /
```

Результат: папка `build/web/` — это и есть твой сайт.

---

## Шаг 5 — Задеплоить на Vercel (бесплатно, HTTPS автоматически)

### Вариант A: через GitHub (рекомендуется)

1. Создать репозиторий на github.com
2. Запушить весь проект:
   ```bash
   git init
   git add .
   git commit -m "initial"
   git remote add origin https://github.com/ТВОЙюзернейм/quran-suras.git
   git push -u origin main
   ```
3. Зайти на vercel.com → "New Project" → выбрать репозиторий
4. В настройках Build:
   - **Build Command:** `flutter build web --release --base-href /`
   - **Output Directory:** `build/web`
5. Нажать Deploy → получить URL: `https://quran-suras.vercel.app`

### Вариант B: через Vercel CLI

```bash
npm i -g vercel
flutter build web --release --base-href /
cd build/web
vercel --prod
# Получишь URL типа https://quran-suras-xxx.vercel.app
```

---

## Шаг 6 — Создать Telegram бота и Mini App

1. Открыть Telegram → найти **@BotFather**
2. Команда `/newbot` → придумать имя и username (например `quran_suras_bot`)
3. Скопировать токен бота
4. Команда `/newapp` → выбрать бота → заполнить:
   - **Title:** 114 Сур Корана
   - **Description:** Учи названия сур Корана интерактивно
   - **URL:** `https://quran-suras.vercel.app` (твой URL с Vercel)
   - Загрузить иконку 640×640 px
5. BotFather даст ссылку вида: `https://t.me/quran_suras_bot/app`

---

## Шаг 7 — Открыть в Telegram

Перейди по ссылке `https://t.me/quran_suras_bot/app` в Telegram — Mini App откроется!

---

## Обновление приложения

```bash
flutter build web --release --base-href /
# Если использовал GitHub+Vercel: просто git push — Vercel сам пересоберёт
git add . && git commit -m "update" && git push
```

---

## Заметки

- `shared_preferences` на web = `localStorage` браузера → прогресс сохраняется между сессиями
- `TelegramService` безопасно работает вне Telegram (haptics и expand просто игнорируются)
- Для добавления новых функций — создавай новые файлы в `screens/` или `widgets/`
