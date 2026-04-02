import 'package:inventra/models/product.model.dart';

abstract class ProductContract {
  Future<List<Product>> getAllProducts();
  Future<int> addProduct(Product product);
  Future<int> removeProduct(int id);
  Future<int> updateProduct(Product product);
}
