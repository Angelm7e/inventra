import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventra/constData/bankList.dart';
import 'package:inventra/contracts/headerColors.dart';
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
  static const int _defaultInvoiceHeaderColor = 0xFF6BD5EF;

  final _formKey = GlobalKey<FormState>();
  final _businessTaxIdController = TextEditingController();
  final _invoicePrefixController = TextEditingController(text: 'INV');
  List<Map<String, String>> _invoiceBankAccounts = [];

  bool _autoPrint = false;
  bool _loading = true;
  int _invoiceHeaderColor = _defaultInvoiceHeaderColor;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper.instance.getBusinessSettings();
    if (!mounted) return;
    setState(() {
      _businessTaxIdController.text = settings['tax_id'] ?? '';
      _invoicePrefixController.text = settings['invoice_prefix'] ?? 'INV';
      _autoPrint = (settings['auto_print'] ?? 0) == 1;
      _invoiceHeaderColor = _readHeaderColor(settings['invoice_header_color']);
      _invoiceBankAccounts = _parseBankAccounts(
        settings['bank_accounts'],
      ).take(3).toList();
      _loading = false;
    });
  }

  int _readHeaderColor(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? _defaultInvoiceHeaderColor;
    return _defaultInvoiceHeaderColor;
  }

  List<Map<String, String>> _parseBankAccounts(dynamic raw) {
    if (raw == null) return [];

    try {
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (item) => item.map(
                  (key, value) =>
                      MapEntry(key.toString(), value?.toString() ?? ''),
                ),
              )
              .map((item) => item.cast<String, String>())
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await DatabaseHelper.instance.saveBusinessSettings({
      'tax_id': _businessTaxIdController.text.trim(),
      'invoice_prefix': _invoicePrefixController.text.trim(),
      'auto_print': _autoPrint ? 1 : 0,
      'invoice_header_color': _invoiceHeaderColor,
      'bank_accounts': jsonEncode(_invoiceBankAccounts.take(3).toList()),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuración guardada correctamente.'),
        backgroundColor: AppColors.lightSuccess,
      ),
    );
  }

  Future<void> _showBankAccountDialog({int? index}) async {
    String? selectedBank = index == null
        ? null
        : _invoiceBankAccounts[index]['bank'];
    final accountController = TextEditingController(
      text: index == null ? '' : _invoiceBankAccounts[index]['account'] ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                index == null
                    ? 'Agregar cuenta bancaria'
                    : 'Editar cuenta bancaria',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedBank,
                    decoration: const InputDecoration(labelText: 'Banco'),
                    items: banckList
                        .map(
                          (bank) =>
                              DropdownMenuItem(value: bank, child: Text(bank)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedBank = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accountController,
                    decoration: const InputDecoration(
                      labelText: 'Número de cuenta',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final accountNumber = accountController.text.trim();
                    if (selectedBank == null || accountNumber.isEmpty) return;

                    setState(() {
                      final account = {
                        'bank': selectedBank!,
                        'account': accountNumber,
                      };
                      if (index == null) {
                        _invoiceBankAccounts.add(account);
                      } else {
                        _invoiceBankAccounts[index] = account;
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.lightSurface,
                  ),
                  child: Text(index == null ? 'Agregar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    accountController.dispose();
  }

  Future<void> _showBankAccountsBottomSheet() async {
    final heightFactor = _invoiceBankAccounts.length <= 1 ? 0.35 : 0.5;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return FractionallySizedBox(
              heightFactor: heightFactor,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cuentas bancarias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _invoiceBankAccounts.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'No hay cuentas bancarias agregadas.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _invoiceBankAccounts.length,
                                itemBuilder: (context, index) {
                                  final account = _invoiceBankAccounts[index];
                                  return _buildBankAccountTile(
                                    index,
                                    account,
                                    onChanged: () => setSheetState(() {}),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBankAccountTile(
    int index,
    Map<String, String> account, {
    VoidCallback? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['bank'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  account['account'] ?? '',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await _showBankAccountDialog(index: index);
              onChanged?.call();
            },
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.lightPrimary,
            tooltip: 'Editar cuenta',
          ),
          IconButton(
            onPressed: () {
              setState(() => _invoiceBankAccounts.removeAt(index));
              onChanged?.call();
            },
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
            tooltip: 'Eliminar cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de encabezado',
          style: TextStyle(fontSize: 16, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: headerColorOptions.map((option) {
            final colorValue = option.color.toARGB32();
            final selected = _invoiceHeaderColor == colorValue;

            return Tooltip(
              message: option.label,
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () => setState(() => _invoiceHeaderColor = colorValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: option.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.lightPrimary
                          : Colors.grey.shade300,
                      width: selected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.lightPrimary,
                          size: 22,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración factura')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'El nombre, dirección y teléfono del negocio se editan desde la pantalla de mantenimiento.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      TextFormField(
                        controller: _businessTaxIdController,
                        decoration: const InputDecoration(
                          labelText: 'NIT / RUC',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _invoicePrefixController,
                        decoration: const InputDecoration(
                          labelText: 'Prefijo de factura',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // SwitchListTile(
                      //   value: _autoPrint,
                      //   title: const Text('Imprimir facturas automáticamente'),
                      //   subtitle: const Text(
                      //     'Al cerrar una venta, envía la factura a la impresora por defecto.',
                      //   ),
                      //   onChanged: (value) => setState(() => _autoPrint = value),
                      // ),
                      const SizedBox(height: 16),
                      _buildHeaderColorPicker(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Cuentas para mostrar en factura',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _showBankAccountsBottomSheet,
                            icon: const Icon(Icons.account_balance_outlined),
                            color: AppColors.lightPrimary,
                            tooltip: 'Ver cuentas bancarias',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_invoiceBankAccounts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Agrega hasta 3 cuentas para mostrarlas en las facturas PDF.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        Column(
                          children: _invoiceBankAccounts
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildBankAccountTile(
                                  entry.key,
                                  entry.value,
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: AppColors.lightPrimary,
                        ),
                        child: const Text(
                          'Guardar configuración',
                          style: TextStyle(color: AppColors.lightSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
