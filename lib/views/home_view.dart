import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/config_controller.dart';
import '../models/servico_model.dart';
import '../services/pdf_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escutando as alterações do Controller
    final config = context.watch<ConfigController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orçamento Pro"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Configuração de Visualização
            Card(
              child: SwitchListTile(
                title: const Text("Ativar Super Funções"),
                subtitle: const Text("Exibição detalhada por categoria e cômodo"),
                value: config.isSuperFuncao,
                onChanged: (_) => config.toggleSuperFuncao(),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              "Minhas Profissões Ativas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Seletor de Profissões Dinâmico
            Wrap(
              spacing: 8.0,
              children: CategoriaProfissional.values.map((cat) {
                final selecionada = config.profissoes.contains(cat);
                return FilterChip(
                  label: Text(cat.name.toUpperCase()),
                  selected: selecionada,
                  onSelected: (_) => config.alternarProfissao(cat),
                  selectedColor: Colors.blue.shade200,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Botão de Geração de Orçamento (Lógica Real)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("GERAR ORÇAMENTO ATUAL"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (config.profissoes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selecione ao menos uma profissão antes.")),
                    );
                    return;
                  }

                  // Criando um objeto de serviço real para o PDF
                  // Futuramente estes dados virão do formulário de cadastro
                  final servicoAtual = Servico(
                    id: DateTime.now().toString(),
                    categoria: config.profissoes.first,
                    subcategoria: 'Serviço Geral',
                    nome: 'Execução de Obra',
                    preco: 0.0, // Valor zerado para preenchimento manual ou vindo do DB
                    quantidade: 1,
                  );

                  await PdfService.gerarOrcamento(
                    nomeCliente: "Novo Cliente",
                    itens: [servicoAtual],
                    isSuperFuncao: config.isSuperFuncao,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Orçamento gerado e salvo com sucesso!")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}