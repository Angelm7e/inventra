import 'package:flutter/material.dart';
import 'package:inventra/models/category.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/provider/categoryProvider.dart';
import 'package:inventra/provider/productProvider.dart';
import 'package:inventra/screens/profile/category/categoryScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/dropDonw.widget.dart';
import 'package:inventra/widgets/texField.widget.dart';
import 'package:provider/provider.dart';

class AddProductToInventoryScreen extends StatefulWidget {
  const AddProductToInventoryScreen({super.key, this.productToEdit});

  final Product? productToEdit;

  static const String routeName = '/addProductToInventoryScreen';

  bool get isEditing => productToEdit != null;

  @override
  State<AddProductToInventoryScreen> createState() =>
      _AddProductToInventoryScreenState();
}

class _AddProductToInventoryScreenState
    extends State<AddProductToInventoryScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productQuantityController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();

  ProductProvider get productProvider =>
      Provider.of<ProductProvider>(context, listen: false);
  CategoryProvider get categoryProvider =>
      Provider.of<CategoryProvider>(context, listen: false);

  String selectedCategory = 'Cargando...';
  bool isLoading = true;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    try {
      isLoading = true;

      categories = await categoryProvider.loadCategories();
      isLoading = false;
      if (categories.isNotEmpty) {
        setState(() {
          final p = widget.productToEdit;
          if (p != null) {
            productNameController.text = p.name;
            productQuantityController.text = p.quantity.toString();
            productPriceController.text = p.price.toString();
            productDescriptionController.text = p.description ?? '';
            final names = categories.map((e) => e.name).toList();
            selectedCategory = names.contains(p.category)
                ? p.category
                : categories.first.name;
          } else {
            selectedCategory = categories.first.name;
          }
        });
      }
      if (categories.isEmpty) {
        setState(() {
          selectedCategory = 'Sin categorías';
          final p = widget.productToEdit;
          if (p != null) {
            productNameController.text = p.name;
            productQuantityController.text = p.quantity.toString();
            productPriceController.text = p.price.toString();
            productDescriptionController.text = p.description ?? '';
          }
        });
        _onCategoryEmpty();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar las categorías.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.lightError,
          ),
        );
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showValidationSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightError,
      ),
    );
  }

  bool _validateProductForm() {
    final name = productNameController.text.trim();
    if (name.isEmpty) {
      _showValidationSnackBar('El nombre del producto es obligatorio.');
      return false;
    }

    final qtyStr = productQuantityController.text.trim();
    if (qtyStr.isEmpty) {
      _showValidationSnackBar('La cantidad es obligatoria.');
      return false;
    }
    final quantity = int.tryParse(qtyStr);
    if (quantity == null || quantity < 0) {
      _showValidationSnackBar(
        'Ingrese una cantidad válida (número entero ≥ 0).',
      );
      return false;
    }

    final priceStr = productPriceController.text.trim();
    if (priceStr.isEmpty) {
      _showValidationSnackBar('El precio es obligatorio.');
      return false;
    }
    final price = int.tryParse(priceStr);
    if (price == null || price < 0) {
      _showValidationSnackBar('Ingrese un precio válido (número entero ≥ 0).');
      return false;
    }

    if (productDescriptionController.text.trim().isEmpty) {
      _showValidationSnackBar('La descripción es obligatoria.');
      return false;
    }

    if (isLoading ||
        categories.isEmpty ||
        selectedCategory == 'Cargando...' ||
        selectedCategory == 'Sin categorías') {
      _showValidationSnackBar('Seleccione una categoría válida.');
      return false;
    }

    return true;
  }

  List<String> get _categoryDropdownItems {
    final names = categories.map((e) => e.name).toList();
    final p = widget.productToEdit;
    if (p != null &&
        p.category.isNotEmpty &&
        !names.contains(p.category)) {
      return [...names, p.category];
    }
    return names;
  }

  @override
  void dispose() {
    productNameController.dispose();
    productQuantityController.dispose();
    productPriceController.dispose();
    productDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Editar producto' : 'Add Product to Inventory',
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    spacing: 10,
                    children: [
                      SizedBox(height: 10),
                      InvTextField(
                        controller: productNameController,
                        hintText: "Element Name",
                        labelText: "Element Name",
                      ),
                      InvTextField(
                        controller: productQuantityController,
                        hintText: "Element Quantity",
                        labelText: "Element Quantity",
                        keyboardType: TextInputType.number,
                      ),
                      InvTextField(
                        controller: productPriceController,
                        hintText: "Element Price",
                        labelText: "Element Price",
                        keyboardType: TextInputType.number,
                      ),
                      InvDropDownWidget(
                        items: _categoryDropdownItems,
                        selectedItem: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        fontSize: 16,
                        icon: Icons.category,
                      ),
                      InvTextField(
                        maxLines: 3,
                        controller: productDescriptionController,
                        hintText: "Element Description",
                        labelText: "Element Description",
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                DatabaseHelper.instance.clearTable();
              },
              child: Text("Clear database"),
            ),
            // Spacer(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onLongPress: () => _onError(isUpdate: widget.isEditing),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full width button
                ),
                onPressed: () {
                  _onAddproduct();
                },
                child: Text(
                  widget.isEditing ? 'Guardar' : 'Agregar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      ),
    );
  }

  void _onCategoryEmpty() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("No hay categorías"),
          content: Text(
            "No se han encontrado categorías. Por favor, agregue al menos una categoría antes de agregar un producto.",
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Aceptar", style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(
                      context,
                      CategoryScreen.routeName,
                    );
                  },
                  child: Text(
                    "Agregar categoría",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onAddproduct() async {
    if (!_validateProductForm()) return;

    final product = Product(
      id: widget.productToEdit?.id,
      name: productNameController.text.trim(),
      quantity: int.parse(productQuantityController.text.trim()),
      price: int.parse(productPriceController.text.trim()),
      category: selectedCategory,
      description: productDescriptionController.text.trim(),
      image: widget.productToEdit?.image,
    );

    final int response;
    if (widget.isEditing) {
      response = await productProvider.updateProduct(product);
    } else {
      response = await productProvider.addProduct(product);
    }

    if (response == -1) {
      _onError(isUpdate: widget.isEditing);
    } else if (response == -2) {
      _onAlreadyExist();
    } else {
      _onSuccess(isUpdate: widget.isEditing);
    }
  }

  void _onAlreadyExist() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Producto existente"),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: "El producto ",
                ),
                TextSpan(
                  text: productNameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text:
                      " ya existe en el inventario, por favor ingrese un nombre diferente.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _onSuccess({required bool isUpdate}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdate ? "Producto actualizado" : "Producto agregado"),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: isUpdate
                      ? "Los datos del producto "
                      : "El producto ",
                ),
                TextSpan(
                  text: productNameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: isUpdate
                      ? " se han guardado correctamente."
                      : " se ha agregado correctamente.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _onError({required bool isUpdate}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error inesperado"),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: isUpdate
                      ? "No se pudo guardar el producto "
                      : "No se pudo agregar el producto ",
                ),
                TextSpan(
                  text: productNameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: ", por favor intente nuevamente.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
}
