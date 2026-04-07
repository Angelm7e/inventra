import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/provider/productProvider.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/utils/number_formatter.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/drawer.dart';
import 'package:provider/provider.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  static const String routeName = '/inventoryListScreen';

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  int _listRefreshKey = 0;

  ProductProvider get _productProvider =>
      Provider.of<ProductProvider>(context, listen: false);

  void _refreshList() {
    setState(() => _listRefreshKey++);
  }

  Future<void> _openAddProduct() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductToInventoryScreen()),
    );
    if (mounted) {
      await _productProvider.loadProducts();
      _refreshList();
    }
  }

  Future<void> _openEditProduct(Product product) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductToInventoryScreen(productToEdit: product),
      ),
    );
    if (mounted) {
      await _productProvider.loadProducts();
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(title: const Text('Inventario')),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshList();
          await _productProvider.loadProducts();
        },
        child: Center(
          child: FutureBuilder<List<Product>>(
            key: ValueKey(_listRefreshKey),
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
                      ? _buildEmpty(context)
                      : ListView(
                          children: snapshot.data!.map((product) {
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
                                        onPressed: (context) =>
                                            _onEdit(product),
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
                                            _onDelete(product),
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
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.10),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              color: AppColors.lightSecondary,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Chip(
                                              label: Text(product.category),
                                              backgroundColor: AppColors
                                                  .lightSecondary
                                                  .withOpacity(0.14),
                                              labelStyle: TextStyle(
                                                color: AppColors.lightSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "Cantidad: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              product.quantity.toString(),
                                              style: product.quantity > 10
                                                  ? const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )
                                                  : const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Precio: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              NumberFormatter.currency(
                                                product.price.toDouble(),
                                              ),
                                              style: product.quantity > 10
                                                  ? const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )
                                                  : const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                            ),
                                          ],
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
          _openAddProduct().catchError((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al agregar productos'),
                backgroundColor: AppColors.lightError,
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        // onTabSelected: (index) {},
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_rounded,
            size: 80,
            color: AppColors.lightSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes productos en tu inventario',
            style: TextStyle(fontSize: 18, color: AppColors.lightTextSecondary),
          ),
          Text(
            'Agrega productos para imprimir tus tickets de venta',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () {
                _openAddProduct().catchError((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al agregar productos'),
                      backgroundColor: AppColors.lightError,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
              child: Text("Agregar productos"),
            ),
          ),
        ],
      ),
    );
  }

  void _onEdit(Product product) {
    _openEditProduct(product);
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
                    if (context.mounted) Navigator.of(context).pop();
                    if (mounted) _refreshList();
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
