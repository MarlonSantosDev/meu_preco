@echo off
echo Gerando keystore para o app Meu Preco...

REM Criar diretório keystore se não existir
if not exist "android\keystore" mkdir "android\keystore"

REM Gerar keystore
keytool -genkey -v -keystore android\keystore\meu_preco.jks -keyalg RSA -keysize 2048 -validity 10000 -alias meu_preco_key -storepass meu_preco_2025 -keypass meu_preco_2025 -dname "CN=Meu Preco, OU=Development, O=Meu Preco App, L=Sao Paulo, S=SP, C=BR"

echo.
echo Keystore gerada com sucesso!
echo Localizacao: android\keystore\meu_preco.jks
echo Alias: meu_preco_key
echo Senha: meu_preco_2025
echo.
echo IMPORTANTE: Guarde essas informacoes em local seguro!
echo.
pause 