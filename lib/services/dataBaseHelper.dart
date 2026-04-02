import 'dart:io';

import 'package:inventra/models/product.model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class DatabaseHelper {
  static final _productTable = "products";
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'iventra.db');
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
    description TEXT
)
''');
  }

  Future<List<Product>> getProduct() async {
    Database db = await instance.database;
    var products = await db.query(_productTable, orderBy: 'name');
    List<Product> productList = products.isNotEmpty
        ? products.map((c) => Product.fromMap(c)).toList()
        : [];
    return productList;
  }

  Future<int> add(Product product) async {
    try {
      Database db = await instance.database;

      final existingProduct = await getProductByName(product.name);

      if (existingProduct != null) {
        return -2;
      }

      return await db.insert(
        _productTable,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      return -1; // Error general
    }
  }

  Future<Product?> getProductByName(String name) async {
    Database db = await instance.database;

    var result = await db.query(
      _productTable,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }

    return null;
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete(_productTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Product product) async {
    Database db = await instance.database;
    return await db.update(
      _productTable,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
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
    final path = join(dbPath, 'product.db');

    await deleteDatabase(path);

    _database = null; // importante para reinicializar
  }
}
