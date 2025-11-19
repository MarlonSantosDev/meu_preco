# Guia de Publicação - Meu Preço

## 🚀 Passo a Passo para Publicação na Google Play Store

### 1. Preparação Inicial

#### 1.1 Gerar Keystore (Primeira vez apenas)
```bash
# Execute o script para gerar a keystore
scripts/generate_keystore.bat
```

**⚠️ IMPORTANTE**: Guarde as informações da keystore em local seguro:
- Arquivo: `android/keystore/meu_preco.jks`
- Alias: `meu_preco_key`
- Senha: `meu_preco_2025`

#### 1.2 Build do AAB
```bash
# Execute o script para gerar o AAB
scripts/build_appbundle.bat
```

O arquivo AAB será gerado em: `build/app/outputs/bundle/release/app-release.aab`

### 2. Google Play Console

#### 2.1 Criar Conta de Desenvolvedor
1. Acesse: https://play.google.com/console
2. Faça login com sua conta Google


#### 2.2 Criar Aplicativo
1. No Play Console, clique em "Criar aplicativo"
2. Preencha as informações básicas:
   - **Nome do app**: Meu Preço
   - **Idioma padrão**: Português (Brasil)
   - **Aplicativo ou jogo**: Aplicativo
   - **Gratuito ou pago**: Gratuito

### 3. Configuração do Aplicativo

#### 3.1 Informações do Aplicativo
- **Nome do app**: Meu Preço
- **Descrição curta**: Calculadora de preços para produtos e receitas
- **Descrição completa**: [Ver PLAY_STORE_INFO.md]
- **Categoria**: Negócios
- **Categoria secundária**: Produtividade
- **Classificação de conteúdo**: Para todos os públicos (3+)

#### 3.2 Upload do AAB
1. Vá para "Produção" → "Criar nova versão"
2. Faça upload do arquivo: `build/app/outputs/bundle/release/app-release.aab`
3. Adicione as notas da versão:
   ```
   Versão inicial do Meu Preço
   - Cadastro de produtos
   - Criação de receitas
   - Precificação automática
   - Relatórios detalhados
   - Gestão de imagens
   ```

#### 3.3 Screenshots
Faça screenshots do app nas seguintes telas:
1. Tela inicial
2. Cadastro de produto
3. Criação de receita
4. Resultado da precificação
5. Relatório detalhado

**Especificações**:
- **Smartphone**: 1080 x 1920 pixels
- **Tablet 7"**: 1200 x 1920 pixels
- **Tablet 10"**: 1920 x 1200 pixels

#### 3.4 Imagem de Destaque
- **Resolução**: 1024 x 500 pixels
- **Formato**: PNG ou JPEG
- **Sem texto ou bordas**

#### 3.5 Ícone do App
- **Resolução**: 512 x 512 pixels
- **Formato**: PNG
- **Fundo transparente**

### 4. Configurações de Distribuição

#### 4.1 Países e Regiões
- **Disponibilidade**: Brasil
- **Idiomas**: Português (Brasil)

#### 4.2 Preço e Distribuição
- **Modelo de preço**: Gratuito
- **Disponibilidade**: Disponível para todos os usuários

#### 4.3 Política de Privacidade
Crie uma página simples com:
```
Política de Privacidade - Meu Preço

O aplicativo Meu Preço não coleta dados pessoais dos usuários.
Todos os dados são salvos localmente no dispositivo do usuário.
Não compartilhamos informações com terceiros.
```

### 5. Revisão e Publicação

#### 5.1 Checklist Final
- [ ] AAB enviado
- [ ] Screenshots adicionadas
- [ ] Descrições preenchidas
- [ ] Política de privacidade configurada
- [ ] Classificação de conteúdo definida
- [ ] Preço configurado
- [ ] Países de disponibilidade selecionados

#### 5.2 Enviar para Revisão
1. Clique em "Revisar versão"
2. Revise todas as informações
3. Clique em "Iniciar lançamento para produção"

#### 5.3 Tempo de Aprovação
- **Primeira publicação**: 1-7 dias
- **Atualizações**: 1-3 dias

### 6. Pós-Publicação

#### 6.1 Monitoramento
- Acompanhe as métricas no Play Console
- Monitore avaliações e comentários
- Verifique crash reports

#### 6.2 Atualizações
Para atualizações futuras:
1. Incremente a versão no `pubspec.yaml`
2. Execute `scripts/build_appbundle.bat`
3. Faça upload do novo AAB no Play Console

---

## 📞 Suporte

Se encontrar problemas durante a publicação:
1. Verifique o [Guia do Desenvolvedor](https://developer.android.com/distribute)
2. Consulte a [Central de Ajuda do Play Console](https://support.google.com/googleplay/android-developer)
3. Verifique os logs de build em caso de erros

---

## 🔧 Troubleshooting

### Erro de Keystore
```
Error: Keystore file not found
```
**Solução**: Execute `scripts/generate_keystore.bat`

### Erro de Build
```
Error: Build failed
```
**Solução**: 
1. Execute `flutter clean`
2. Execute `flutter pub get`
3. Tente novamente o build

### Erro de Upload
```
Error: Upload failed
```
**Solução**: Verifique se o AAB foi gerado corretamente e se não excede 150MB

---

## 📋 Checklist Rápido

- [ ] Keystore gerada
- [ ] AAB criado
- [ ] Conta de desenvolvedor ativa
- [ ] Aplicativo criado no Play Console
- [ ] Informações preenchidas
- [ ] Screenshots adicionadas
- [ ] AAB enviado
- [ ] Revisão iniciada

**🎉 Boa sorte com a publicação!** 