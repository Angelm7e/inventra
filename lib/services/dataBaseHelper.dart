import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class DatabaseHelper {
  static final _productTable = "products";
  static final _databaseName = "iventra.db";
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE
      )
    ''');

    await db.execute('''
  CREATE TABLE products(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    quantity INTEGER,
    price INTEGER,
    category TEXT,
    description TEXT,
    image TEXT 
  )
  ''');

    await db.execute('''
  CREATE TABLE printers(
    id TEXT PRIMARY KEY,
    name TEXT,
    type TEXT,
    address TEXT,
    port INTEGER
  )
  ''');

    await db.execute('''
  CREATE TABLE business_settings(
    id INTEGER PRIMARY KEY CHECK (id = 1),
    name TEXT,
    tax_id TEXT,
    address TEXT,
    phone TEXT,
    logo_path TEXT,
    invoice_prefix TEXT,
    auto_print INTEGER DEFAULT 0,
    bank_accounts TEXT
  )
  ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS business_settings(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT,
        tax_id TEXT,
        address TEXT,
        phone TEXT,
        logo_path TEXT,
        invoice_prefix TEXT,
        auto_print INTEGER DEFAULT 0,
        bank_accounts TEXT
      )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE business_settings ADD COLUMN logo_path TEXT',
      );
    }

    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE business_settings ADD COLUMN bank_accounts TEXT',
      );
      await db.execute(
        "UPDATE business_settings SET bank_accounts = '[]' WHERE bank_accounts IS NULL",
      );
    }
  }

  Future<Map<String, dynamic>> getBusinessSettings() async {
    final db = await database;
    final response = await db.query('business_settings', where: 'id = 1');
    if (response.isEmpty) return {};
    return response.first;
  }

  Future<void> saveBusinessSettings(Map<String, dynamic> settings) async {
    final db = await database;
    final current = await getBusinessSettings();
    final payload = <String, dynamic>{
      'id': 1,
      'name': current['name'],
      'tax_id': current['tax_id'],
      'address': current['address'],
      'phone': current['phone'],
      'logo_path': current['logo_path'],
      'invoice_prefix': current['invoice_prefix'] ?? 'INV',
      'auto_print': current['auto_print'] ?? 0,
      'bank_accounts': current['bank_accounts'] ?? '[]',
      ...settings,
    };
    await db.insert(
      'business_settings',
      payload,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Exportar a JSON
  Future<File> exportToJson() async {
    final db = await database;

    final data = await db.query(_productTable);

    final jsonString = jsonEncode(data);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products_backup.json');

    return await file.writeAsString(jsonString);
  }

  // Compartir el backup usando share_plus
  Future<void> shareBackup() async {
    final file = await exportToJson();

    await Share.shareXFiles([XFile(file.path)], text: 'Backup de productos');
  }

  // Importar desde un JSON
  Future<void> importFromJson(File file) async {
    final db = await database;

    final content = await file.readAsString();

    List<dynamic> data = jsonDecode(content);

    for (var item in data) {
      await db.insert(
        _productTable,
        Map<String, dynamic>.from(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  //Para limpiar la tabla, útil para pruebas o para reiniciar el inventario
  Future<void> clearTable() async {
    final db = await database;
    final response = await db.delete(_productTable);
    print(response);
  }

  // Para eliminar la base de datos completa, este es solo para pruebas
  // TODO: eliminar este método o protegerlo con una confirmación, para evitar borrados accidentales
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    await deleteDatabase(path);

    _database = null; // importante para reinicializar
  }
}
