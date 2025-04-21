import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do aplicativo
            Center(child: Column(children: [Image.asset('assets/images/imagem_home.png', height: 100), const SizedBox(height: 16), Text('Meu Preço', style: Theme.of(context).textTheme.headlineMedium), const Text('Versão 1.0.0', style: TextStyle(fontSize: 16, color: Colors.grey)), const SizedBox(height: 24)])),

            // Descrição do app
            const _SectionTitle(title: 'Sobre o aplicativo'),
            const _ContentText(
              text:
                  'O Meu Preço é um aplicativo para cálculo de preços de produtos e gerenciamento de receitas. '
                  'Com ele, você pode cadastrar seus insumos, criar receitas e calcular o preço de venda de '
                  'forma precisa, incluindo custos de ingredientes, mão de obra e gastos adicionais.',
            ),
            const SizedBox(height: 16),

            // Como utilizar
            const _SectionTitle(title: 'Como utilizar'),
            const _ContentText(
              text:
                  '1. Cadastre seus produtos (insumos) com preço e quantidade\n'
                  '2. Crie receitas, informando os produtos utilizados e suas quantidades\n'
                  '3. Ajuste os percentuais de gastos embutidos e mão de obra\n'
                  '4. Veja o preço de venda calculado automaticamente\n'
                  '5. Quando o preço de um produto for alterado, todas as receitas que o utilizam serão recalculadas',
            ),
            const SizedBox(height: 16),

            // Medidas de referência
            const _SectionTitle(title: 'Medidas de referência'),
            const _MedidasTable(),
            const SizedBox(height: 16),

            // Licença
            const _SectionTitle(title: 'Licença de uso'),
            const _ContentText(
              text:
                  'Este aplicativo é distribuído sob licença de software livre.\n'
                  'Você pode usar, modificar e distribuir conforme suas necessidades.',
            ),
            const SizedBox(height: 16),

            // Desenvolvedor
            const _SectionTitle(title: 'Desenvolvedor'),
            const _ContentText(
              text:
                  'Desenvolvido por: Marlon Santos\n'
                  'Contato: marlon-20-12@hotmail.com',
            ),
            const SizedBox(height: 16),

            // Créditos
            const _SectionTitle(title: 'Créditos'),
            const _ContentText(
              text:
                  'Imagens: Unsplash (API)\n'
                  'Licença de imagens: Unsplash License',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
  }
}

class _ContentText extends StatelessWidget {
  final String text;

  const _ContentText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }
}

class _MedidasTable extends StatelessWidget {
  const _MedidasTable();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [DataColumn(label: Text('Medida')), DataColumn(label: Text('Equivalência'))],
        rows: const [
          DataRow(cells: [DataCell(Text('1 xícara (chá)')), DataCell(Text('240ml'))]),
          DataRow(cells: [DataCell(Text('1 xícara (café)')), DataCell(Text('50ml'))]),
          DataRow(cells: [DataCell(Text('1 colher (sopa)')), DataCell(Text('15ml'))]),
          DataRow(cells: [DataCell(Text('1 colher (chá)')), DataCell(Text('5ml'))]),
          DataRow(cells: [DataCell(Text('1 colher (café)')), DataCell(Text('2,5ml'))]),
          DataRow(cells: [DataCell(Text('1/4 xícara')), DataCell(Text('60ml'))]),
          DataRow(cells: [DataCell(Text('1/3 xícara')), DataCell(Text('80ml'))]),
          DataRow(cells: [DataCell(Text('1/2 xícara')), DataCell(Text('120ml'))]),
          DataRow(cells: [DataCell(Text('1 copo americano')), DataCell(Text('200ml'))]),
        ],
      ),
    );
  }
}
