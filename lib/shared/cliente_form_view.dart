import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/validators.dart';
import '../database/db_helper.dart';

class ClienteFormView extends StatefulWidget {
  const ClienteFormView({super.key});

  @override
  State<ClienteFormView> createState() => _ClienteFormViewState();
}

class _ClienteFormViewState extends State<ClienteFormView> {
  final _formKey = GlobalKey<FormState>();
  bool isPessoaFisica = true;
  String documento = "";
  bool documentoValido = true;

  // Controllers
  final _nomeController = TextEditingController();
  final _docController = TextEditingController();
  final _cepController = TextEditingController();
  final _cidadeController = TextEditingController(); // Aqui entrará o seletor de pré-cadastro depois

  void _validarDocumento(String value) {
    setState(() {
      documento = value;
      documentoValido = isPessoaFisica 
          ? Validators.isValidCPF(value) 
          : Validators.isValidCNPJ(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Cliente")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Seletor PF/PJ
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text("Pessoa Física"), icon: Icon(Icons.person)),
                  ButtonSegment(value: false, label: Text("Pessoa Jurídica"), icon: Icon(Icons.business)),
                ],
                selected: {isPessoaFisica},
                onSelectionChanged: (val) => setState(() {
                  isPessoaFisica = val.first;
                  _docController.clear();
                  documentoValido = true;
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome/Razão Social", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              // Campo Documento com Alerta Vermelho
              TextFormField(
                controller: _docController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isPessoaFisica ? "CPF" : "CNPJ",
                  border: const OutlineInputBorder(),
                  errorText: documentoValido ? null : "Documento Inválido (Aviso)",
                  errorStyle: const TextStyle(color: Colors.red),
                  suffixIcon: Icon(
                    documentoValido ? Icons.check_circle : Icons.warning,
                    color: documentoValido ? Colors.green : Colors.red,
                  ),
                ),
                onChanged: _validarDocumento,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(labelText: "CEP (00000-000)", border: OutlineInputBorder()),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: "Número", border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(decoration: const InputDecoration(labelText: "Endereço/Logradouro", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextFormField(decoration: const InputDecoration(labelText: "Bairro", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              // Cidade/Estado (Placeholder para o módulo de pré-cadastro)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Cidade/Região", border: OutlineInputBorder()),
                items: ["Igarapava - SP", "Franca - SP", "Ribeirão Preto - SP"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {},
              ),
              const SizedBox(height: 15),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Observações", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Salvar no Banco
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cliente salvo no banco local.")));
                  },
                  child: const Text("SALVAR CLIENTE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}