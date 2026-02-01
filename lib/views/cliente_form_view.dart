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
  
  // Estado do Formulário
  bool isPessoaFisica = true;
  bool documentoValido = true;
  List<Map<String, dynamic>> _cidadesDisponiveis = [];
  int? _cidadeSelecionadaId;

  // Controllers para capturar os dados
  final _nomeController = TextEditingController();
  final _docController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarCidades(); // Busca as cidades do banco ao abrir a tela
  }

  Future<void> _carregarCidades() async {
    final cidades = await DbHelper().getCidades();
    setState(() {
      _cidadesDisponiveis = cidades;
    });
  }

  void _validarDocumento(String value) {
    setState(() {
      documentoValido = isPessoaFisica 
          ? Validators.isValidCPF(value) 
          : Validators.isValidCNPJ(value);
    });
  }

  Future<void> _salvar() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome é obrigatório")));
      return;
    }

    final dados = {
      'nome': _nomeController.text,
      'tipo_pessoa': isPessoaFisica ? 'PF' : 'PJ',
      'documento': _docController.text,
      'whatsapp': '', // Campo para expansão futura
      'email': '',    // Campo para expansão futura
      'cep': _cepController.text,
      'logradouro': _logradouroController.text,
      'numero': _numeroController.text,
      'bairro': _bairroController.text,
      'cidade_id': _cidadeSelecionadaId,
      'observacoes': _obsController.text,
      'data_cadastro': DateTime.now().toIso8601String(),
    };

    await DbHelper().insertCliente(dados);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cliente salvo com sucesso!")));
      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Cliente")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                decoration: const InputDecoration(labelText: "Nome / Razão Social", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _docController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isPessoaFisica ? "CPF" : "CNPJ",
                  border: const OutlineInputBorder(),
                  // Lógica do alerta vermelho sem impedir o prosseguimento
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: documentoValido ? Colors.grey : Colors.red, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: documentoValido ? Colors.blue : Colors.red, width: 2),
                  ),
                  suffixIcon: Icon(
                    documentoValido ? Icons.check_circle : Icons.error,
                    color: documentoValido ? Colors.green : Colors.red,
                  ),
                ),
                onChanged: _validarDocumento,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(labelText: "CEP", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(labelText: "Nº", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(labelText: "Endereço", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: "Bairro", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              
              // Dropdown Dinâmico que consome do Banco de Dados
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Cidade / Região (Pré-cadastradas)", border: OutlineInputBorder()),
                value: _cidadeSelecionadaId,
                items: _cidadesDisponiveis.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'],
                    child: Text("${c['nome']} - ${c['estado']}"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _cidadeSelecionadaId = val),
              ),
              
              const SizedBox(height: 15),
              TextFormField(
                controller: _obsController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Observações do Cliente", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.save),
                  label: const Text("SALVAR NO BANCO LOCAL"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}