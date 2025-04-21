import 'package:hive_flutter/hive_flutter.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';

class HiveInit {
  static const String produtosBoxName = 'produtos';
  static const String receitasBoxName = 'receitas';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar os adaptadores
    Hive.registerAdapter(ProdutoAdapter());
    Hive.registerAdapter(ReceitaAdapter());
    Hive.registerAdapter(IngredienteAdapter());

    // Abrir as boxes
    await Hive.openBox<Produto>(produtosBoxName);
    await Hive.openBox<Receita>(receitasBoxName);
  }
}
