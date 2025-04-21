# Meu Preço

Aplicativo para precificação de produtos e receitas culinárias, desenvolvido em Flutter com foco em simplicidade e facilidade de uso.

![Logo do Aplicativo](assets/images/icone.jpg)

## Sobre o Aplicativo

O Meu Preço é um aplicativo que ajuda empreendedores do setor alimentício a calcular corretamente o preço de venda de suas receitas, considerando o custo dos ingredientes, gastos indiretos e margem de lucro desejada.

## Funcionalidades Principais

### Cadastro de Produtos
- Cadastre os ingredientes utilizados nas suas receitas
- Informe preço e quantidade dos produtos (ex: 1kg de arroz por R$ 10,00)
- Adicione fotos dos produtos via:
  - Câmera
  - Galeria
  - Busca online (API Unsplash)

### Criação de Receitas
- Crie receitas utilizando os produtos cadastrados
- Defina a quantidade de cada ingrediente na receita
- Configure percentuais de gastos indiretos e mão de obra
- Visualize detalhadamente o preço de venda sugerido
- Adicione fotos das receitas via câmera, galeria ou busca online

### Precificação Automática
- Cálculo automático do custo de ingredientes
- Adição de percentual de gastos indiretos (padrão: 20%)
- Adição de percentual de mão de obra (padrão: 20%)
- Atualização automática do preço ao modificar ingredientes ou seus custos

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento multiplataforma
- **Dart**: Linguagem de programação
- **Hive**: Banco de dados local para persistência
- **Provider**: Gerenciamento de estado
- **Go Router**: Navegação
- **Unsplash API**: Busca de imagens online

## Arquitetura

O aplicativo segue a arquitetura Clean Architecture com o padrão MVC:

- **Model**: Entidades e regras de negócio
- **View**: Interface do usuário
- **Controller**: Gerenciamento da lógica de negócio e comunicação entre Model e View

### Estrutura de Diretórios

```
lib/
├── core/          # Funcionalidades centrais e utilitários
├── data/          # Camada de dados e serviços externos
├── domain/        # Entidades e regras de negócio
├── presentation/  # Interface do usuário (Telas, Widgets e Controllers)
└── main.dart      # Ponto de entrada do aplicativo
```

## Instalação e Uso

### Requisitos
- Flutter SDK 3.7.2 ou superior
- Dart SDK
- Android Studio ou Visual Studio Code

## Fluxo de Uso
1. **Cadastre seus Produtos**
   - Informe nome, preço e quantidade de cada produto
   - Adicione uma imagem se desejar

2. **Crie suas Receitas**
   - Adicione ingredientes da lista de produtos
   - Defina a quantidade utilizada de cada ingrediente
   - Configure os percentuais de gastos e mão de obra
   - Adicione uma imagem para a receita

3. **Visualize a Precificação**
   - Veja o custo detalhado de cada ingrediente
   - Analise os custos adicionais aplicados
   - Obtenha o preço de venda sugerido

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para mais detalhes.

## Contato

Para sugestões ou dúvidas, entre em contato através do email: marlon-20-12@hotmail.com

---

Desenvolvido com ❤️ usando Flutter.
