import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class CidadeCadastroView extends StatefulWidget {
  const CidadeCadastroView({super.key});

  @override
  State<CidadeCadastroView> createState() => _CidadeCadastroViewState();
}

class _CidadeCadastroViewState extends State<CidadeCadastroView> {
  final _nomeController = TextEditingController();
  String _estadoSelecionado = 'SP';
  final List<String> _estados = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'];

  void _salvarCidade() async {
    if (_nomeController.text.isEmpty) return;
    
    await DbHelper().insertCidade(_nomeController.text.trim(), _estadoSelecionado);
    _nomeController.clear();
    setState(() {}); // Atualiza a lista abaixo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cidade cadastrada!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pré-Cadastro de Cidades")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: "Nome da Cidade", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _estadoSelecionado,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _estadoSelecionado = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _salvarCidade, child: const Text("ADICIONAR CIDADE")),
            ),
            const Divider(height: 30),
            const Text("Cidades Atendidas:", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DbHelper().getCidades(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text("${item['nome']} - ${item['estado']}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}