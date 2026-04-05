import 'package:flutter/material.dart';

class AddPrintersScreen extends StatefulWidget {
  const AddPrintersScreen({super.key});

  static const String routeName = '/addPrintersScreen';

  @override
  State<AddPrintersScreen> createState() => _AddPrintersScreenState();
}

class _AddPrintersScreenState extends State<AddPrintersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Printers')),
      body: const Center(child: Text('Add Printers Screen')),
    );
  }
}
