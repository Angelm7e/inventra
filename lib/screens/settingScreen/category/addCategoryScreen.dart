import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  static const String routeName = '/addCategoryScreen';

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: const Center(child: Text('Add Category Screen')),
    );
  }
}
