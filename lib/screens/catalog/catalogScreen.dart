import 'package:flutter/material.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/provider/billing_provider.dart';
import 'package:inventra/provider/quoteProvider.dart';
import 'package:inventra/screens/catalog/catalog_cart_target.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/services/productService.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/utils/number_formatter.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/product_card.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  static const String routeName = '/catalogScreen';

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  String? _selectedCategory;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ProductService().getAllProducts();
      setState(() {
        _products = list;
        _loading = false;
        if (_selectedCategory == null && list.isNotEmpty) {
          final cats = list.map((e) => e.category).toSet().toList()..sort();
          _selectedCategory = cats.first;
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'No se pudieron cargar los productos.';
      });
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == null) return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  List<String> get _categories {
    return _products.map((e) => e.category).toSet().toList()..sort();
  }

  CatalogCartTarget get _cartTarget {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is CatalogCartTarget ? args : CatalogCartTarget.billing;
  }

  @override
  Widget build(BuildContext context) {
    final cartTarget = _cartTarget;
    final addLabel =
        cartTarget == CatalogCartTarget.quote ? 'Cotizar' : 'Facturar';
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _loadProducts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              if (_categories.length > 1) _buildCategoryChips(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      addButtonLabel: addLabel,
                      onAddToQuote: () =>
                          _showAddProductSheet(product, cartTarget),
                    );
                  }, childCount: _filteredProducts.length),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 6),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 50,
      floating: true,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Catálogo de productos', style: TextStyle(fontSize: 20)),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AddProductToInventoryScreen.routeName,
              ).then((_) => _loadProducts());
            },
            icon: const Icon(Icons.add, color: AppColors.lightPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Todos'),
                selected: _selectedCategory == null,
                onSelected: (_) => setState(() => _selectedCategory = null),
                selectedColor: AppColors.lightPrimary,
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.grey[800]),
              ),
            ),
            ..._categories.map((cat) {
              final selected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.lightPrimary,
                  checkmarkColor: Colors.blue,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddProductSheet(Product product, CatalogCartTarget target) {
    if (target == CatalogCartTarget.billing) {
      final canAdd = context.read<BillingProvider>().availableToAdd(product);
      if (canAdd <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sin stock disponible para "${product.name}"'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    int quantity = 1;
    final maxForBilling = target == CatalogCartTarget.billing
        ? context.read<BillingProvider>().availableToAdd(product)
        : 99999;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormatter.currency(product.price.toDouble()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (target == CatalogCartTarget.billing) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Disponible para facturar: $maxForBilling',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      'En inventario: ${product.quantity} (la cotización no descuenta stock)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: quantity > 1
                            ? () => setModalState(() => quantity--)
                            : null,
                        icon: Icon(
                          Icons.remove,
                          color: quantity > 1
                              ? Colors.white
                              : AppColors.lightPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: quantity < maxForBilling
                            ? () => setModalState(() => quantity++)
                            : null,
                        icon: const Icon(Icons.add, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (target == CatalogCartTarget.quote) {
                        sheetContext.read<QuoteProvider>().addToQuote(
                              product,
                              quantity: quantity,
                            );
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Se agregaron $quantity ítem(s) a la cotización',
                            ),
                            backgroundColor: AppColors.lightSuccess,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        final billing = sheetContext.read<BillingProvider>();
                        final allowed = billing.availableToAdd(product);
                        if (allowed <= 0) {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'No hay stock suficiente para esta cantidad',
                              ),
                              backgroundColor: Colors.orange.shade800,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final q = quantity.clamp(1, allowed);
                        billing.addToBilling(product, quantity: q);
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Se agregaron $q ítem(s) a la factura',
                            ),
                            backgroundColor: AppColors.lightSuccess,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: Text(
                      target == CatalogCartTarget.quote
                          ? 'Agregar a cotización'
                          : 'Agregar a factura',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
