enum CategoriaProfissional { pintor, eletricista, pedreiro, gesseiro, encanador }

class Servico {
  final String id;
  final CategoriaProfissional categoria;
  final String subcategoria;
  final String nome;
  final String? comodo;
  final double preco;
  final int quantidade;

  Servico({
    required this.id,
    required this.categoria,
    required this.subcategoria,
    required this.nome,
    this.comodo,
    required this.preco,
    this.quantidade = 1,
  });

  String formatarParaExibicao(bool isSuperFuncao) {
    String p = "R\$ ${preco.toStringAsFixed(2)}";
    if (isSuperFuncao) {
      return "$quantidade serviço (${categoria.name.toUpperCase()}) ($subcategoria) (${comodo ?? 'Geral'}) $p";
    }
    return "$quantidade serviço (${categoria.name.toUpperCase()}) $p";
  }
}