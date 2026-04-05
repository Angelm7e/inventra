import 'package:inventra/contracts/categoryContract.dart';
import 'package:inventra/models/category.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class CategoryService implements CategoryContract {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String table = "categories";

  Future<Database> get _db async => await _dbHelper.database;

  @override
  Future<List<Category>> getCategories() async {
    final db = await _db;

    final result = await db.query(table, orderBy: 'name ASC');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final db = await _db;

    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);

    return result.isNotEmpty ? Category.fromMap(result.first) : null;
  }

  @override
  Future<int> updateCategory(Category category) async {
    try {
      final db = await _db;

      final existingCategory = await getCategoryByName(category.name);
      if (existingCategory != null) {
        return -2;
      }

      return await db.update(
        table,
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      return -1; // Error general
    }
  }

  @override
  Future<int> addCategory(Category category) async {
    try {
      final db = await _db;

      final existingCategory = await getCategoryByName(category.name);

      if (existingCategory != null) {
        return -2;
      }

      return await db.insert(
        table,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      return -1; // Error general
    }
  }

  @override
  Future<int> removeCategory(int id) async {
    final db = await _db;

    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Category?> getCategoryByName(String name) async {
    Database db = await _dbHelper.database;

    var result = await db.query(
      table,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Category.fromMap(result.first);
    }

    return null;
  }
}
