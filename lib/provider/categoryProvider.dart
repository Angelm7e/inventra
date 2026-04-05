import 'package:flutter/material.dart';
import 'package:inventra/contracts/categoryContract.dart';
import 'package:inventra/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryContract categoryContract;

  CategoryProvider(this.categoryContract);

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<List<Category>> loadCategories() async {
    _categories = await categoryContract.getCategories();
    notifyListeners();
    return _categories;
  }

  Future<int> addCategory(Category category) async {
    int result = await categoryContract.addCategory(category);
    if (result > 0) {
      await loadCategories();
    }
    return result;
  }

  Future<int> removeCategory(int id) async {
    int result = await categoryContract.removeCategory(id);
    if (result > 0) {
      await loadCategories();
    }
    return result;
  }

  Future<int> updateCategory(Category category) async {
    int result = await categoryContract.updateCategory(category);
    if (result > 0) {
      await loadCategories();
    }
    return result;
  }
}
