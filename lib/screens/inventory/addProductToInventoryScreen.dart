import 'package:flutter/material.dart';
import 'package:inventra/models/product.model.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/dropDonw.widget.dart';
import 'package:inventra/widgets/texField.widget.dart';

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

  String selectedCategory = 'Category 1';

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
                        items: ['Category 1', 'Category 2', 'Category 3'],
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
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 2,
          // onTabSelected: (index) {}, //TODO: will probably need to change this to navigate to the correct screen
        ),
      ),
    );
  }

  _onAddproduct() async {
    final response = await DatabaseHelper.instance.add(
      Product(
        name: productNameController.text,
        quantity: int.tryParse(productQuantityController.text) ?? 0,
        price: int.tryParse(productPriceController.text) ?? 0,
        category: selectedCategory,
        description: productDescriptionController.text,
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

  _onAlreadyExist() {
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

  _onSuccess() {
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
                Navigator.popAndPushNamed(
                  context,
                  InventoryListScreen.routeName,
                );
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  _onError() {
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
