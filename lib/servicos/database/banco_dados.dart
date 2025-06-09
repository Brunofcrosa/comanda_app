import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_comandas_app/modelos/comanda.dart';
import 'package:flutter_comandas_app/modelos/item_comanda.dart';
import 'package:flutter_comandas_app/modelos/usuario.dart';
import 'package:flutter_comandas_app/modelos/comprovante.dart';

class BancoDados {
  static final BancoDados instancia = BancoDados._init();
  static Database? _database;

  BancoDados._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('comandas_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE comandas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        data_criacao TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE itens_comanda (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comanda_id INTEGER,
        nome TEXT,
        quantidade INTEGER,
        preco REAL,
        caminho_foto TEXT,
        FOREIGN KEY(comanda_id) REFERENCES comandas(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE comprovantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caminhoArquivo TEXT NOT NULL,
        dataCaptura TEXT NOT NULL,
        idComandaVinculada INTEGER,
        descricao TEXT,
        FOREIGN KEY (idComandaVinculada) REFERENCES comandas (id) ON DELETE SET NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE itens_comanda ADD COLUMN caminho_foto TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          senha TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS receitas');
      await db.execute('DROP TABLE IF EXISTS despesas');
      await db.execute('DROP TABLE IF EXISTS comprovantes');

      await db.execute('''
        CREATE TABLE comprovantes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          caminhoArquivo TEXT NOT NULL,
          dataCaptura TEXT NOT NULL,
          idComandaVinculada INTEGER,
          descricao TEXT,
          FOREIGN KEY (idComandaVinculada) REFERENCES comandas (id) ON DELETE SET NULL
        )
      ''');
    }
  }

  Future<int> inserirUsuario(Usuario usuario) async {
    final db = await instancia.database;
    return await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final db = await instancia.database;
    final maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<int> salvarComanda(Comanda comanda) async {
    final db = await database;
    return await db.transaction((txn) async {
      final id = await txn.insert('comandas', comanda.toMap());
      await _salvarItensComanda(txn, id, comanda.itens);
      return id;
    });
  }

  Future<int> atualizarComanda(Comanda comanda) async {
    final db = await database;
    if (comanda.id == null) {
      throw Exception("Comanda ID não pode ser nulo para atualização.");
    }
    return await db.transaction((txn) async {
      await txn.update(
        'comandas',
        comanda.toMap(),
        where: 'id = ?',
        whereArgs: [comanda.id],
      );
      await txn.delete(
        'itens_comanda',
        where: 'comanda_id = ?',
        whereArgs: [comanda.id],
      );
      await _salvarItensComanda(txn, comanda.id!, comanda.itens);
      return comanda.id!;
    });
  }

  Future<void> removerComanda(int id) async {
    final db = await database;
    await db.delete(
      'comprovantes',
      where: 'idComandaVinculada = ?',
      whereArgs: [id],
    );
    await db.delete('comandas', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Comanda>> listarComandas() async {
    final db = await database;
    final List<Map<String, dynamic>> mapasComandas = await db.query(
      'comandas',
      orderBy: 'data_criacao DESC',
    );
    final List<Comanda> comandas = [];
    for (var mapaComanda in mapasComandas) {
      final comanda = Comanda.fromMap(mapaComanda);
      final List<Map<String, dynamic>> mapasItens = await db.query(
        'itens_comanda',
        where: 'comanda_id = ?',
        whereArgs: [comanda.id],
      );
      final List<ItemComanda> itens = mapasItens
          .map((i) => ItemComanda.fromMap(i))
          .toList();
      comandas.add(comanda.copyWith(itens: itens));
    }
    return comandas;
  }

  Future<void> _salvarItensComanda(
    DatabaseExecutor txn,
    int comandaId,
    List<ItemComanda> itens,
  ) async {
    for (var item in itens) {
      await txn.insert(
        'itens_comanda',
        item.toMapWithComandaId(comandaId: comandaId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> inserirComprovante(Comprovante comprovante) async {
    final db = await instancia.database;
    return await db.insert(
      'comprovantes',
      comprovante.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Comprovante>> listarComprovantes() async {
    final db = await instancia.database;
    final maps = await db.query('comprovantes', orderBy: 'dataCaptura DESC');
    return List.generate(maps.length, (i) => Comprovante.fromMap(maps[i]));
  }

  Future<List<Comprovante>> listarComprovantesPorComanda(int idComanda) async {
    final db = await instancia.database;
    final maps = await db.query(
      'comprovantes',
      where: 'idComandaVinculada = ?',
      whereArgs: [idComanda],
      orderBy: 'dataCaptura DESC',
    );
    return List.generate(maps.length, (i) => Comprovante.fromMap(maps[i]));
  }

  Future<int> removerComprovante(int id) async {
    final db = await instancia.database;
    return await db.delete('comprovantes', where: 'id = ?', whereArgs: [id]);
  }

  Future<Comanda?> buscarComandaPorId(int id) async {
    final db = await instancia.database;
    final maps = await db.query(
      'comandas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Comanda.fromMap(maps.first) : null;
  }

  Future close() async {
    final db = await instancia.database;
    db.close();
  }
}

extension on ItemComanda {
  Map<String, dynamic> toMapWithComandaId({required int comandaId}) {
    final map = toMap();
    map['comanda_id'] = comandaId;
    return map;
  }
}
