#!/bin/sh

# Этот скрипт должен выполняться на macOS с установленным Go и Xcode Command Line Tools

# 1. Устанавливаем gomobile, если он не установлен
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# 2. Переходим в директорию с Go-кодом
cd GoCore

# 3. Собираем Go-код в нативный iOS Framework
#    -target=ios указывает на целевую платформу
#    -o ../iOSApp/GoCore.xcframework указывает, куда положить готовый фреймворк
#    github.com/google/gopacket может вызвать проблемы при сборке под iOS из-за CGo зависимостей.
#    Для реальной сборки может потребоваться кастомная конфигурация или использование чистого Go форка.
#    Этот скрипт - демонстрация намерения.
echo "Собираем Go-ядро в GoCore.xcframework..."
gomobile bind -target=ios -o ../iOSApp/GoCore.xcframework .

echo "Сборка завершена. Фреймворк находится в директории iOSApp/."
echo "Теперь его можно добавить в Xcode проект."

