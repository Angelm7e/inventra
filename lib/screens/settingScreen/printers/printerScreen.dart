import 'package:flutter/material.dart';
import 'package:inventra/screens/settingScreen/category/addCategoryScreen.dart';
import 'package:inventra/screens/settingScreen/printers/addPrinterScreen.dart';

class PrintersScreen extends StatefulWidget {
  const PrintersScreen({super.key});

  static const String routeName = '/printersScreen';

  @override
  State<PrintersScreen> createState() => _PrintersScreenState();
}

class _PrintersScreenState extends State<PrintersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impresoras')),
      body: const Center(child: Text('Pantalla de impresoras')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddPrintersScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
