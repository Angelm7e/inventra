import 'package:inventra/models/category.dart';

abstract class CategoryContract {
  Future<List<Category>> getCategories();
  Future<int> addCategory(Category category);
  Future<int> removeCategory(int id);
  Future<int> updateCategory(Category category);
  Future<Category?> getCategoryById(int id);
}
