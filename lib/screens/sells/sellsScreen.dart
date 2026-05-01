import 'package:flutter/material.dart';

class SellsScreen extends StatelessWidget {
  const SellsScreen({super.key});
  static const routeName = '/sellsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: const Center(child: Text('Pantalla para ver las ventas')),
    );
  }
}
