import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/provider/productProvider.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:provider/provider.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  static const String routeName = '/inventoryListScreen';

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  ProductProvider get _productProvider =>
      Provider.of<ProductProvider>(context, listen: false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: SizedBox(), title: const Text('Inventario')),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {});
          return Future.delayed(Duration(seconds: 1));
        },
        child: Center(
          child: FutureBuilder<List<Product>>(
            future: _productProvider.loadProducts(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error cargando productos.'),
                    );
                  }
                  return snapshot.data!.isEmpty
                      ? const Center(child: Text('No products in List.'))
                      : ListView(
                          children: snapshot.data!.map((Product) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Slidable(
                                  startActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      CustomSlidableAction(
                                        padding: EdgeInsets.zero,
                                        onPressed: (context) => _onEdit(),
                                        backgroundColor: AppColors.lightSuccess,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 5),

                                      CustomSlidableAction(
                                        padding: EdgeInsets.zero,
                                        onPressed: (context) =>
                                            _onDelete(Product),
                                        backgroundColor: AppColors.lightError,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              Product.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          Product.category,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          Product.quantity.toString(),
                                          style: Product.quantity > 10
                                              ? const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                )
                                              : const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddProductToInventoryScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        // onTabSelected: (index) {},
      ),
    );
  }

  _onEdit() {
    print("Edited");
  }

  _onDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '¿Estás seguro de que deseas eliminar el producto ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                TextSpan(
                  text: product.name,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: '?',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () async {
                    await _productProvider.removeProduct(product.id!);
                    _productProvider.loadProducts();
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
