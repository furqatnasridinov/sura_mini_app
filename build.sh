#!/bin/bash

# скачиваем Flutter
git clone https://github.com/flutter/flutter.git --depth 1

# добавляем в PATH
export PATH="$PATH:`pwd`/flutter/bin"

# проверка
flutter doctor

# билд
flutter build web