import 'package:flutter/material.dart';
import '../models/servico_model.dart';

class ConfigController extends ChangeNotifier {
  bool _isSuperFuncao = false;
  bool get isSuperFuncao => _isSuperFuncao;

  final Set<CategoriaProfissional> _profissoesSelecionadas = {};
  Set<CategoriaProfissional> get profissoes => _profissoesSelecionadas;

  void toggleSuperFuncao() {
    _isSuperFuncao = !_isSuperFuncao;
    notifyListeners();
  }

  void alternarProfissao(CategoriaProfissional cat) {
    if (_profissoesSelecionadas.contains(cat)) {
      _profissoesSelecionadas.remove(cat);
    } else {
      _profissoesSelecionadas.add(cat);
    }
    notifyListeners();
  }
}