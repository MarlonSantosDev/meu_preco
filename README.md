# Meu Preço

Aplicativo para precificação de produtos baseado em receitas e insumos.

## Sobre

O Meu Preço é um aplicativo desenvolvido em Flutter para ajudar a calcular o preço de venda de produtos baseado nos insumos utilizados, gastos adicionais e mão de obra.

## Funcionalidades

- Cadastro de insumos (produtos) com preço e quantidade
- Criação de receitas com os insumos cadastrados
- Cálculo automático do preço de venda com base em:
  - Custo dos ingredientes
  - Gastos "escondidos" (customizável)
  - Mão de obra (customizável)
- Detalhamento completo da precificação

## Configuração do Ambiente

1. Certifique-se de ter o Flutter instalado (versão 3.7.0 ou superior)
2. Clone este repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute o script `run_build_runner.cmd` para gerar os arquivos necessários para o Hive
5. Execute `flutter run` para iniciar o aplicativo

## Arquitetura

O aplicativo foi desenvolvido seguindo os princípios da Clean Architecture e o padrão MVC:

- **Domain**: Contém as entidades e casos de uso
- **Data**: Implementa os repositórios e fontes de dados
- **Presentation**: Contém os controladores e telas

## Dependências Principais

- **hive**: Banco de dados local
- **provider**: Gerenciamento de estado
- **go_router**: Navegação
- **intl**: Formatação de números e moeda
