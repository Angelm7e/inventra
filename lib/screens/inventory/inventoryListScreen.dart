import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventra/models/category.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/provider/categoryProvider.dart';
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
  String? _selectedCategory;

  ProductProvider get _productProvider =>
      Provider.of<ProductProvider>(context, listen: false);

  CategoryProvider get _categoryProvider =>
      Provider.of<CategoryProvider>(context, listen: false);

  void _refreshList() {
    setState(() => _listRefreshKey++);
  }

  Future<_InventoryData> _loadInventoryData() async {
    final products = await _productProvider.loadProducts();
    final categories = await _categoryProvider.loadCategories();
    return _InventoryData(products: products, categories: categories);
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

  Future<void> _handleAddProductPressed() async {
    try {
      await _openAddProduct();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar productos'),
          backgroundColor: AppColors.lightError,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          await _categoryProvider.loadCategories();
        },
        child: Center(
          child: FutureBuilder<_InventoryData>(
            key: ValueKey(_listRefreshKey),
            future: _loadInventoryData(),
            builder:
                (BuildContext context, AsyncSnapshot<_InventoryData> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error cargando productos.'),
                    );
                  }

                  final products = snapshot.data!.products;
                  final categoryNames = snapshot.data!.categories
                      .map((category) => category.name.trim())
                      .where((name) => name.isNotEmpty)
                      .toList();
                  final selectedCategory =
                      _selectedCategory != null &&
                          categoryNames.contains(_selectedCategory)
                      ? _selectedCategory
                      : null;
                  final filteredProducts = selectedCategory == null
                      ? products
                      : products
                            .where(
                              (product) =>
                                  product.category.trim() == selectedCategory,
                            )
                            .toList();

                  if (products.isEmpty) {
                    return _buildEmpty(context);
                  }

                  return ListView(
                    children: [
                      _buildCategoryFilters(categoryNames, selectedCategory),
                      if (filteredProducts.isEmpty)
                        _buildNoFilteredProducts(selectedCategory!)
                      else
                        ...filteredProducts.map(_buildProductItem),
                    ],
                  );
                },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddProductPressed,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        // onTabSelected: (index) {},
      ),
    );
  }

  Widget _buildCategoryFilters(
    List<String> categoryNames,
    String? selectedCategory,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Todos',
              selected: selectedCategory == null,
              onSelected: () => setState(() => _selectedCategory = null),
            ),
            ...categoryNames.map(
              (category) => _buildFilterChip(
                label: category,
                selected: selectedCategory == category,
                onSelected: () => setState(() => _selectedCategory = category),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        checkmarkColor: AppColors.lightPrimary.withValues(alpha: 0.5),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: Colors.white,
        backgroundColor: AppColors.lightSecondary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: selected
              ? AppColors.lightSecondary
              : AppColors.lightTextSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: selected
              ? AppColors.lightPrimary.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Slidable(
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              CustomSlidableAction(
                padding: EdgeInsets.zero,
                onPressed: (context) => _onEdit(product),
                backgroundColor: AppColors.lightSuccess,
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 26, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      'Editar',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 5),

              CustomSlidableAction(
                padding: EdgeInsets.zero,
                onPressed: (context) => _onDelete(product),
                backgroundColor: AppColors.lightError,
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 26, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
                color: AppColors.lightPrimary.withOpacity(0.3),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.10),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.lightPrimary.withOpacity(0.8),
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
                      backgroundColor: AppColors.lightSecondary.withValues(
                        alpha: 0.14,
                      ),
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
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                      NumberFormatter.currency(product.price.toDouble()),
                      style: product.quantity > 10
                          ? const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
  }

  Widget _buildNoFilteredProducts(String selectedCategory) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.filter_list_off,
              size: 56,
              color: AppColors.lightTextSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay productos en $selectedCategory',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
              onPressed: _handleAddProductPressed,
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

  void _onDelete(Product product) {
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

class _InventoryData {
  final List<Product> products;
  final List<Category> categories;

  _InventoryData({required this.products, required this.categories});
}
