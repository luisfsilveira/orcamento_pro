import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ClienteListView extends StatefulWidget {
  const ClienteListView({super.key});

  @override
  State<ClienteListView> createState() => _ClienteListViewState();
}

class _ClienteListViewState extends State<ClienteListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Clientes")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Busca todos os clientes do banco
        future: DbHelper().db.then((db) => db.query('clientes', orderBy: 'nome ASC')),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("Nenhum cliente cadastrado."));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final cliente = snapshot.data![index];
              
              return FutureBuilder<Map<String, int>>(
                // Inteligência de Orçamentos: Busca aprovados vs recusados
                future: DbHelper().getHistoricoCliente(cliente['id']),
                builder: (context, histSnapshot) {
                  final aprovados = histSnapshot.data?['aprovados'] ?? 0;
                  final recusados = histSnapshot.data?['recusados'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(cliente['nome']),
                      subtitle: Text(
                        "Histórico: $aprovados aprovados / $recusados recusados",
                        style: TextStyle(
                          color: recusados > aprovados ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Ação futura: Iniciar orçamento para este cliente
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}