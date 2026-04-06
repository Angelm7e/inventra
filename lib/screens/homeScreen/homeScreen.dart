import 'package:flutter/material.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/services/printerService/printerService.dart';
import 'package:inventra/widgets/bottomNavBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: SizedBox(), title: const Text('Home Screen')),
      body: Column(
        children: [
          Text('Welcome to the Home Screen!'),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, CatalogScreen.routeName);
            },
            child: Text('Go to Catalog'),
          ),
          TextButton(
            onPressed: () {
              PrinterService(ip: '10.0.0.67').printInvoice([
                {
                  'name': 'Product 1',
                  'quantity': 1,
                  'price': 100,
                  'subtotal': 100,
                },
                {
                  'name': 'Product 2',
                  'quantity': 1,
                  'price': 100,
                  'subtotal': 100,
                },
                {
                  'name': 'Product 3',
                  'quantity': 1,
                  'price': 100,
                  'subtotal': 100,
                },
                {
                  'name': 'Product 4',
                  'quantity': 1,
                  'price': 100,
                  'subtotal': 100,
                },
              ]);
            },
            child: Text('Print Invoice'),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        // onTabSelected: (index) {},
      ),
    );
  }
}
