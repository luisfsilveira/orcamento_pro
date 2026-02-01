import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/config_controller.dart';
import '../models/servico_model.dart';
import '../services/pdf_service.dart';
import 'cliente_list_view.dart';
import 'cliente_form_view.dart';
import 'cidade_cadastro_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orçamento Pro"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu Orçamento Pro",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Meus Clientes"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClienteListView())),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Novo Cliente"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClienteFormView())),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text("Pré-Cadastro de Cidades"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CidadeCadastroView())),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard de Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text("Gráficos de Orçamentos (Em breve)")),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("GERAR ORÇAMENTO RÁPIDO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  // VALIDAÇÃO RESTAURADA: Verifica se há profissões antes de prosseguir
                  if (config.profissoes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selecione ao menos uma profissão antes.")),
                    );
                    return;
                  }

                  // OBJETO COMPLETO: Restaurado conforme sua lógica original
                  final servicoAtual = Servico(
                    id: DateTime.now().toString(),
                    categoria: config.profissoes.first,
                    subcategoria: 'Serviço Geral',
                    nome: 'Execução de Obra',
                    preco: 0.0,
                    quantidade: 1,
                  );

                  await PdfService.gerarOrcamento(
                    nomeCliente: "Novo Cliente",
                    itens: [servicoAtual],
                    isSuperFuncao: config.isSuperFuncao,
                  );

                  // SEGURANÇA RESTAURADA: Verifica se o widget ainda está montado
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Orçamento gerado!")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Futura implementação: Fluxo completo de novo orçamento
        },
        label: const Text("Novo Orçamento"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}