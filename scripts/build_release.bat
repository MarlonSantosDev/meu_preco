@echo off
echo ========================================
echo Build de Release - Meu Preco
echo ========================================

REM Limpar builds anteriores
echo Limpando builds anteriores...
flutter clean

REM Obter dependências
echo Obtendo dependências...
flutter pub get

REM Gerar código
echo Gerando código...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Gerar ícones
echo Gerando ícones...
flutter pub run flutter_launcher_icons:main

REM Build de release
echo Gerando APK de release...
flutter build apk --release

echo.
echo ========================================
echo Build concluído!
echo ========================================
echo APK localizado em: build\app\outputs\flutter-apk\app-release.apk
echo.
echo Para gerar AAB (recomendado para Play Store):
echo flutter build appbundle --release
echo.
pause 