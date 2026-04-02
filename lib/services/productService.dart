import 'package:inventra/contracts/productContract.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class ProductService implements ProductContract {
  final dbHelper = DatabaseHelper.instance;
  final String table = "products";

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await dbHelper.database;

    final result = await db.query(table, orderBy: 'name');

    return result.map((e) => Product.fromMap(e)).toList();
  }

  @override
  Future<int> addProduct(Product product) async {
    try {
      final db = await dbHelper.database;

      final existing = await getByName(product.name);

      if (existing != null) return -2;

      return await db.insert(
        table,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<int> removeProduct(int id) async {
    final db = await dbHelper.database;

    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> updateProduct(Product product) async {
    final db = await dbHelper.database;

    return await db.update(
      table,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<Product?> getByName(String name) async {
    final db = await dbHelper.database;

    final result = await db.query(
      table,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }

    return null;
  }

  //JOIN con categoría para obtener el nombre de la categoría junto con los productos
  // Future<List<Map<String, dynamic>>> getWithCategory() async {
  //   final db = await dbHelper.database;

  //   return await db.rawQuery('''
  //     SELECT
  //       p.*,
  //       c.name as categoryName
  //     FROM products p
  //     LEFT JOIN categories c ON p.categoryId = c.id
  //   ''');
  // }
}
