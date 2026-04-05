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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
