import 'package:flutter/material.dart';
import 'package:inventra/models/printerDevice.dart';
import 'package:inventra/provider/printerProvider.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/dropDonw.widget.dart';
import 'package:inventra/widgets/texField.widget.dart';
import 'package:provider/provider.dart';

class AddPrintersScreen extends StatefulWidget {
  const AddPrintersScreen({super.key, this.printerToEdit});

  final PrinterDevice? printerToEdit;

  static const String routeName = '/addPrintersScreen';

  bool get isEditing => printerToEdit != null;

  @override
  State<AddPrintersScreen> createState() => _AddPrintersScreenState();
}

class _AddPrintersScreenState extends State<AddPrintersScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController portController = TextEditingController(
    text: '9100',
  );

  PrinterProvider get printerProvider =>
      Provider.of<PrinterProvider>(context, listen: false);

  static const List<String> _typeLabels = ['Red', 'Bluetooth'];
  static const List<String> _typeValues = ['network', 'bluetooth'];

  String selectedTypeLabel = _typeLabels.first;

  @override
  void initState() {
    super.initState();
    final p = widget.printerToEdit;
    if (p != null) {
      nameController.text = p.name;
      addressController.text = p.address;
      portController.text = (p.port ?? 9100).toString();
      final idx = _typeValues.indexOf(p.type);
      if (idx >= 0) {
        selectedTypeLabel = _typeLabels[idx];
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    portController.dispose();
    super.dispose();
  }

  String get _selectedTypeValue =>
      _typeValues[_typeLabels.indexOf(selectedTypeLabel)];

  void _showValidationSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightError,
      ),
    );
  }

  bool _validatePrinterForm() {
    if (nameController.text.trim().isEmpty) {
      _showValidationSnackBar('El nombre es obligatorio.');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      _showValidationSnackBar('La dirección es obligatoria.');
      return false;
    }
    final portStr = portController.text.trim();
    if (portStr.isEmpty) {
      _showValidationSnackBar('El puerto es obligatorio.');
      return false;
    }
    final port = int.tryParse(portStr);
    if (port == null || port < 1 || port > 65535) {
      _showValidationSnackBar('Ingrese un puerto válido (1-65535).');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Editar impresora' : 'Agregar impresora',
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
                      const SizedBox(height: 10),
                      InvTextField(
                        controller: nameController,
                        hintText: 'Nombre de la impresora',
                        labelText: 'Nombre',
                      ),
                      InvDropDownWidget(
                        items: _typeLabels,
                        selectedItem: selectedTypeLabel,
                        onChanged: (value) {
                          setState(() {
                            selectedTypeLabel = value!;
                          });
                        },
                        fontSize: 16,
                        icon: Icons.print,
                      ),
                      InvTextField(
                        controller: addressController,
                        hintText: '10.0.0.1',
                        labelText: 'Dirección IP',
                      ),
                      InvTextField(
                        controller: portController,
                        hintText: 'Puerto (ej. 9100)',
                        labelText: 'Puerto',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _onSavePrinter,
                child: Text(
                  widget.isEditing ? 'Guardar' : 'Agregar',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      ),
    );
  }

  void _onSavePrinter() async {
    if (!_validatePrinterForm()) return;

    final device = PrinterDevice(
      id:
          widget.printerToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      type: _selectedTypeValue,
      address: addressController.text.trim(),
      port: int.parse(portController.text.trim()),
    );

    final int response;
    if (widget.isEditing) {
      response = await printerProvider.updatePrinter(device);
    } else {
      response = await printerProvider.addPrinter(device);
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
          title: const Text('Impresora existente'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: 'La impresora ',
                ),
                TextSpan(
                  text: nameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text:
                      ' ya está registrada, por favor ingrese un nombre diferente.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
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
          title: Text(
            isUpdate ? 'Impresora actualizada' : 'Impresora agregada',
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  style: const TextStyle(fontSize: 16),
                  text: isUpdate ? 'Los datos de ' : 'La impresora ',
                ),
                TextSpan(
                  text: nameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  style: const TextStyle(fontSize: 16),
                  text: isUpdate
                      ? ' se han guardado correctamente.'
                      : ' se ha agregado correctamente.',
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
              child: const Text('Aceptar'),
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
          title: const Text('Error inesperado'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  style: const TextStyle(fontSize: 16),
                  text: isUpdate
                      ? 'No se pudo guardar la impresora '
                      : 'No se pudo agregar la impresora ',
                ),
                TextSpan(
                  text: nameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: ', por favor intente nuevamente.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
