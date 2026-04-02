import 'package:flutter/foundation.dart';
import 'package:inventra/contracts/productContract.dart';
import 'package:inventra/models/product.model.dart';

class Productprovider with ChangeNotifier {
  final ProductContract productContract;

  Productprovider(this.productContract);

  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await productContract.getAllProducts();
    notifyListeners();
  }

  Future<int> addProduct(Product product) async {
    final response = await productContract.addProduct(product);
    await loadProducts();
    return response;
  }

  Future<void> removeProduct(int id) async {
    await productContract.removeProduct(id);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await loadProducts();
  }
}
