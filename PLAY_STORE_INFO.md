# Informações para Publicação na Google Play Store

## Dados do Aplicativo

### Nome do App
**Meu Preço**

### Package Name
`com.meupreco.app`

### Versão
1.0.0 (versionCode: 1)

## Descrição Curta (80 caracteres)
Calculadora de preços para produtos e receitas

## Descrição Completa
**Meu Preço** - A ferramenta essencial para empreendedores, cozinheiros e pequenos negócios calcularem preços de forma profissional e lucrativa.

### ✨ Principais Funcionalidades:

**📦 Cadastro de Produtos**
• Registre produtos com preço e quantidade
• Exemplo: 1kg de arroz por R$ 10,00
• Organize seu estoque de forma simples

**👨‍🍳 Criação de Receitas**
• Selecione produtos e quantidades utilizadas
• Calcule custos automaticamente
• Visualize composição completa do preço

**💰 Precificação Automática**
• Cálculo automático de custos
• Margem de lucro configurável (padrão 20%)
• Mão de obra configurável (padrão 20%)
• Gastos indiretos incluídos

**📊 Relatórios Detalhados**
• Custo total da receita
• Preço de venda sugerido
• Margem de lucro
• Composição completa do preço
• Preço por unidade (kg, ml, etc.)

**🖼️ Gestão de Imagens**
• Busca automática de imagens
• Upload de fotos personalizadas
• Interface visual intuitiva

### 🎯 Ideal para:
• Empreendedores iniciantes
• Cozinheiros profissionais
• Pequenos negócios
• Food trucks
• Confeitarias
• Restaurantes
• Qualquer pessoa que precise precificar produtos

### 💡 Por que escolher o Meu Preço?
• Interface simples e intuitiva
• Cálculos automáticos e precisos
• Dados salvos localmente no seu dispositivo
• Sem necessidade de internet para usar
• Totalmente em português brasileiro
• Moeda em Real (R$)

### 🔒 Privacidade
Todos os seus dados ficam salvos no seu dispositivo. Não coletamos informações pessoais.

### 📱 Compatibilidade
• Android 5.0 (API 21) ou superior
• Otimizado para smartphones e tablets
• Interface responsiva

---

## Palavras-chave Sugeridas
precificação, preço, receita, custo, lucro, margem, produto, calculadora, empreendedor, cozinheiro, food truck, confeitaria, restaurante, negócio, vendas, precificar

## Categoria Principal
**Negócios**

## Categoria Secundária
**Produtividade**

## Classificação de Conteúdo
**Para todos os públicos (3+)**

## Preço
**Gratuito**

## País de Disponibilidade
**Brasil**

## Idiomas
**Português (Brasil)**

## Screenshots Sugeridas (5-8 imagens)
1. Tela inicial com lista de produtos
2. Cadastro de produto
3. Criação de receita
4. Seleção de ingredientes
5. Resultado da precificação
6. Relatório detalhado
7. Gestão de imagens
8. Configurações

## Imagem de Destaque
- Resolução: 1024 x 500 pixels
- Formato: PNG ou JPEG
- Sem texto ou bordas

## Ícone do App
- Resolução: 512 x 512 pixels
- Formato: PNG
- Fundo transparente

## Política de Privacidade
URL: [Criar página de política de privacidade]

## Termos de Serviço
URL: [Criar página de termos de serviço]

---

## Checklist de Publicação

### ✅ Configurações Técnicas
- [x] Keystore configurada
- [x] ProGuard configurado
- [x] AndroidManifest.xml otimizado
- [x] Versão atualizada
- [x] AAB gerado

### 📋 Documentação Necessária
- [ ] Screenshots do app (5-8 imagens)
- [ ] Imagem de destaque (1024x500)
- [ ] Ícone do app (512x512)
- [ ] Política de privacidade
- [ ] Termos de serviço

### 🎯 Play Console
- [ ] Conta de desenvolvedor criada
- [ ] Aplicativo criado no console
- [ ] Informações básicas preenchidas
- [ ] AAB enviado
- [ ] Screenshots enviadas
- [ ] Descrições preenchidas
- [ ] Classificação de conteúdo definida
- [ ] Preço definido
- [ ] Países de disponibilidade selecionados

---

## Comandos para Build

### Gerar Keystore (primeira vez)
```bash
scripts/generate_keystore.bat
```

### Build de Release (APK)
```bash
scripts/build_release.bat
```

### Build para Play Store (AAB)
```bash
scripts/build_appbundle.bat
```

### Comandos manuais
```bash
# Limpar e obter dependências
flutter clean
flutter pub get

# Gerar código
flutter packages pub run build_runner build --delete-conflicting-outputs

# Gerar ícones
flutter pub run flutter_launcher_icons:main

# Build AAB para Play Store
flutter build appbundle --release
```

---

## Informações da Keystore
- **Arquivo**: `android/keystore/meu_preco.jks`
- **Alias**: `meu_preco_key`
- **Senha**: `meu_preco_2025`
- **Validade**: 10.000 dias

**⚠️ IMPORTANTE**: Guarde essas informações em local seguro! A perda da keystore impossibilita atualizações futuras do app. 