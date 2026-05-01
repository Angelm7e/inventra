import 'package:flutter/material.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';

class BusinessInvoiceSettingsScreen extends StatefulWidget {
  const BusinessInvoiceSettingsScreen({super.key});

  static const String routeName = '/businessInvoiceSettings';

  @override
  State<BusinessInvoiceSettingsScreen> createState() =>
      _BusinessInvoiceSettingsScreenState();
}

class _BusinessInvoiceSettingsScreenState
    extends State<BusinessInvoiceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTaxIdController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _invoicePrefixController = TextEditingController(text: 'INV');

  bool _autoPrint = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper.instance.getBusinessSettings();
    if (!mounted) return;
    setState(() {
      _businessNameController.text = settings['name'] ?? '';
      _businessTaxIdController.text = settings['tax_id'] ?? '';
      _businessAddressController.text = settings['address'] ?? '';
      _businessPhoneController.text = settings['phone'] ?? '';
      _invoicePrefixController.text = settings['invoice_prefix'] ?? 'INV';
      _autoPrint = (settings['auto_print'] ?? 0) == 1;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await DatabaseHelper.instance.saveBusinessSettings({
      'name': _businessNameController.text.trim(),
      'tax_id': _businessTaxIdController.text.trim(),
      'address': _businessAddressController.text.trim(),
      'phone': _businessPhoneController.text.trim(),
      'invoice_prefix': _invoicePrefixController.text.trim(),
      'auto_print': _autoPrint ? 1 : 0,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuración guardada correctamente.'),
        backgroundColor: AppColors.lightSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de negocio y facturas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Ingresa el nombre del negocio'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _businessTaxIdController,
                      decoration: const InputDecoration(labelText: 'NIT / RUC'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _businessAddressController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _businessPhoneController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _invoicePrefixController,
                      decoration: const InputDecoration(labelText: 'Prefijo de factura'),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _autoPrint,
                      title: const Text('Imprimir facturas automáticamente'),
                      subtitle: const Text('Al cerrar una venta, envía la factura a la impresora por defecto.'),
                      onChanged: (value) => setState(() => _autoPrint = value),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppColors.lightPrimary,
                      ),
                      child: const Text('Guardar configuración'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
