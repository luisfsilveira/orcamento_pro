import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class PrazoConfigView extends StatefulWidget {
  const PrazoConfigView({super.key});

  @override
  State<PrazoConfigView> createState() => _PrazoConfigViewState();
}

class _PrazoConfigViewState extends State<PrazoConfigView> {
  final _descController = TextEditingController();
  final _diasController = TextEditingController();

  void _salvar() async {
    if (_descController.text.isEmpty || _diasController.text.isEmpty) return;
    await DbHelper().insertPrazo(_descController.text, int.parse(_diasController.text));
    _descController.clear();
    _diasController.clear();
    setState(() {}); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prazo cadastrado!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurar Prazos Padrão")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(controller: _descController, decoration: const InputDecoration(labelText: "Descrição (Ex: Validade Padrão)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextFormField(
              controller: _diasController, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(labelText: "Quantidade de Dias", border: OutlineInputBorder())
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: _salvar, child: const Text("SALVAR NO PRÉ-CADASTRO")),
            ),
            const Divider(height: 40),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DbHelper().getPrazos(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final p = snapshot.data![index];
                      return ListTile(
                        leading: const Icon(Icons.timer),
                        title: Text(p['descricao']),
                        trailing: Text("${p['dias']} dias"),
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