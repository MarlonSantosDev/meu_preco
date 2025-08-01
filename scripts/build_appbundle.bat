@echo off
echo ========================================
echo Build AAB - Meu Preco (Play Store)
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

REM Build de AAB
echo Gerando AAB para Play Store...
flutter build appbundle --release

echo.
echo ========================================
echo Build AAB concluído!
echo ========================================
echo AAB localizado em: build\app\outputs\bundle\release\app-release.aab
echo.
echo Este arquivo está pronto para upload na Google Play Console!
echo.
pause 