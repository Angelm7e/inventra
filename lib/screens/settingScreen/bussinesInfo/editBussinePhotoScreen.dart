import 'package:flutter/material.dart';

class EditBussinesPhotoScreen extends StatefulWidget {
  const EditBussinesPhotoScreen({super.key});

  static const String routeName = "/editBussinesPhotoScreen";

  @override
  State<EditBussinesPhotoScreen> createState() =>
      _EditBussinesPhotoScreenState();
}

class _EditBussinesPhotoScreenState extends State<EditBussinesPhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Foto del Negocio')),
      body: const Center(
        child: Text('Pantalla para editar la foto del negocio'),
      ),
    );
  }
}
