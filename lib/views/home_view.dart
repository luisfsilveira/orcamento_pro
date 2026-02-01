import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/config_controller.dart';
import '../models/servico_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Orçamento Pro")),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Ativar Super Funções"),
            value: config.isSuperFuncao,
            onChanged: (_) => config.toggleSuperFuncao(),
          ),
          const Divider(),
          const Text("Selecione suas Profissões:"),
          Wrap(
            children: CategoriaProfissional.values.map((cat) {
              return FilterChip(
                label: Text(cat.name),
                selected: config.profissoes.contains(cat),
                onSelected: (_) => config.alternarProfissao(cat),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}