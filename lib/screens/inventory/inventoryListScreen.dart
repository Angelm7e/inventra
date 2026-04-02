import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  static const String routeName = '/inventoryListScreen';

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
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
            future: DatabaseHelper.instance.getProduct(),
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
                                      SlidableAction(
                                        spacing: 5,
                                        borderRadius: BorderRadius.circular(10),
                                        onPressed: (context) {
                                          _onEdit();
                                        },
                                        backgroundColor: AppColors.darkPrimary,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                      ),
                                      SlidableAction(
                                        spacing: 5,
                                        borderRadius: BorderRadius.circular(10),
                                        onPressed: (context) {
                                          _onDelete();
                                        },
                                        backgroundColor: AppColors.darkPrimary,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                      ),
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

  _onDelete() {
    print("Deleted");
  }
}
