import 'package:flutter/material.dart';
import 'package:inventra/models/category.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/provider/categoryProvider.dart';
import 'package:inventra/provider/productProvider.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/screens/settingScreen/category/categoryScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/dropDonw.widget.dart';
import 'package:inventra/widgets/texField.widget.dart';
import 'package:provider/provider.dart';

class AddProductToInventoryScreen extends StatefulWidget {
  const AddProductToInventoryScreen({super.key});

  static const String routeName = '/addProductToInventoryScreen';

  @override
  State<AddProductToInventoryScreen> createState() =>
      _AddProductToInventoryScreenState();
}

class _AddProductToInventoryScreenState
    extends State<AddProductToInventoryScreen> {
  final TextEditingController passwordController = TextEditingController();
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
          selectedCategory = categories.first.name;
        });
      }
      if (categories.isEmpty) {
        selectedCategory = 'Sin categorías';
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

  @override
  dispose() {
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
        appBar: AppBar(title: const Text('Add Product to Inventory')),
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
                        items: categories.map((e) => e.name).toList(),
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
                onLongPress: _onError,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full width button
                ),
                onPressed: () {
                  _onAddproduct();
                },
                child: Text("Agregar", style: TextStyle(fontSize: 18)),
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
    final response = await productProvider.addProduct(
      Product(
        name: productNameController.text,
        quantity: int.tryParse(productQuantityController.text) ?? 0,
        price: int.tryParse(productPriceController.text) ?? 0,
        category: selectedCategory,
        description: productDescriptionController.text,
        image: null,
      ),
    );
    if (response == -1) {
      _onError();
    } else if (response == -2) {
      _onAlreadyExist();
    } else {
      _onSuccess();
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

  void _onSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Producto agregado"),
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
                  text: " se ha agregado correctamente.",
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

  void _onError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error inesperado"),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: "No se pudo agregar el producto ",
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
