import 'package:flutter/material.dart';

class EditBussinesInfoScreen extends StatefulWidget {
  const EditBussinesInfoScreen({super.key});

  static const String routeName = "/editBussinesInfoScreen";

  @override
  State<EditBussinesInfoScreen> createState() => _EditBussinesInfoScreenState();
}

class _EditBussinesInfoScreenState extends State<EditBussinesInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Información')),
      body: const Center(
        child: Text('Pantalla para editar la información del negocio'),
      ),
    );
  }
}
