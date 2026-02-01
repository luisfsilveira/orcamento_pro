import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // Alterado para orcamento_pro conforme sua orientação
    String path = join(await getDatabasesPath(), 'orcamento_pro.db');
    
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: (db, version) async {
        // Tabela de Clientes atualizada com campos PF/PJ e Endereço completo
        await db.execute('''
          CREATE TABLE clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            nome TEXT NOT NULL, 
            tipo_pessoa TEXT, -- 'PF' ou 'PJ'
            documento TEXT,   -- CPF ou CNPJ
            whatsapp TEXT, 
            email TEXT,
            cep TEXT,
            logradouro TEXT,
            numero TEXT,
            bairro TEXT,
            cidade_id INTEGER, -- Chave estrangeira para a tabela cidades
            observacoes TEXT,
            data_cadastro TEXT
          )
        ''');

        // Tabela de Orçamentos
        await db.execute('''
          CREATE TABLE orçamentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            cliente_id INTEGER, 
            status TEXT, 
            data_validade TEXT, 
            total REAL, 
            super_funcao INTEGER,
            FOREIGN KEY (cliente_id) REFERENCES clientes (id)
          )''');

        // NOVA: Tabela de Cidades para o Pré-Cadastro
        await db.execute('''
          CREATE TABLE cidades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            estado TEXT NOT NULL,
            UNIQUE(nome, estado)
          )
        ''');
      },
    );
  }

  // --- MÉTODOS PARA CIDADES ---

  Future<int> insertCidade(String nome, String estado) async {
    final dbClient = await db;
    return await dbClient.insert('cidades', {'nome': nome, 'estado': estado});
  }

  Future<List<Map<String, dynamic>>> getCidades() async {
    final dbClient = await db;
    return await dbClient.query('cidades', orderBy: 'nome ASC');
  }

  // --- MÉTODOS PARA CLIENTES ---

  Future<int> insertCliente(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.insert('clientes', row);
  }

  // Inteligência de histórico do cliente (Mantida conforme sua versão)
  Future<Map<String, int>> getHistoricoCliente(int clienteId) async {
    final dbClient = await db;
    var res = await dbClient.rawQuery(
      'SELECT status, COUNT(*) as qtd FROM orçamentos WHERE cliente_id = ? GROUP BY status', [clienteId]
    );
    
    Map<String, int> mapa = {"aprovados": 0, "recusados": 0};
    for (var row in res) {
      if (row['status'] == 'aprovado') mapa['aprovados'] = row['qtd'] as int;
      if (row['status'] == 'recusado') mapa['recusados'] = row['qtd'] as int;
    }
    return mapa;
  }
}