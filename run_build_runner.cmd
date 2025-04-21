@echo off
echo Gerando arquivos adaptadores do Hive...
flutter pub run build_runner build --delete-conflicting-outputs
echo Concluído!
pause 