import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:inventra/constData/bankList.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';

class EditBussinesInfoScreen extends StatefulWidget {
  const EditBussinesInfoScreen({super.key});

  static const String routeName = "/editBussinesInfoScreen";

  @override
  State<EditBussinesInfoScreen> createState() => _EditBussinesInfoScreenState();
}

class _EditBussinesInfoScreenState extends State<EditBussinesInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();

  final _bankAccountController = TextEditingController();
  List<Map<String, String>> _bankAccounts = [];
  String? _selectedBank;
  int? _editingIndex;

  String? _businessLogoPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessInfo();
  }

  Future<void> _loadBusinessInfo() async {
    final settings = await DatabaseHelper.instance.getBusinessSettings();
    if (!mounted) return;
    setState(() {
      _businessNameController.text = settings['name'] ?? '';
      _businessAddressController.text = settings['address'] ?? '';
      _businessPhoneController.text = settings['phone'] ?? '';
      _businessLogoPath = settings['logo_path'];
      _bankAccounts = _parseBankAccounts(settings['bank_accounts']);
      _loading = false;
    });
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
      if (raw is List) {
        return raw
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
    } catch (_) {}
    return [];
  }

  Future<void> _pickLogo(ImageSource source) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (result == null) return;
    try {
      final bytes = await result.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'business_logo${p.extension(result.path)}';
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        _businessLogoPath = file.path;
      });
    } catch (e) {
      // fallback to original path if copy fails
      setState(() {
        _businessLogoPath = result.path;
      });
    }
  }

  void _showLogoPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.lightPrimary,
                ),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickLogo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.lightPrimary,
                ),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickLogo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.redAccent),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveBusinessInfo() async {
    if (!_formKey.currentState!.validate()) return;

    await DatabaseHelper.instance.saveBusinessSettings({
      'name': _businessNameController.text.trim(),
      'address': _businessAddressController.text.trim(),
      'phone': _businessPhoneController.text.trim(),
      'logo_path': _businessLogoPath,
      'bank_accounts': jsonEncode(_bankAccounts),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Información del negocio guardada correctamente.'),
        backgroundColor: AppColors.lightSuccess,
      ),
    );
  }

  Future<void> _showBankAccountDialog({int? index}) async {
    if (index != null) {
      _selectedBank = _bankAccounts[index]['bank'];
      _bankAccountController.text = _bankAccounts[index]['account'] ?? '';
      _editingIndex = index;
    } else {
      _selectedBank = null;
      _bankAccountController.clear();
      _editingIndex = null;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
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
                initialValue: _selectedBank,
                decoration: const InputDecoration(labelText: 'Banco'),
                items: banckList
                    .map(
                      (bank) =>
                          DropdownMenuItem(value: bank, child: Text(bank)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedBank = value),
                validator: (value) =>
                    value == null ? 'Selecciona un banco' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankAccountController,
                decoration: const InputDecoration(
                  labelText: 'Número de cuenta',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (_selectedBank == null ||
                    _bankAccountController.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  final account = {
                    'bank': _selectedBank!,
                    'account': _bankAccountController.text.trim(),
                  };
                  if (_editingIndex != null) {
                    _bankAccounts[_editingIndex!] = account;
                  } else {
                    _bankAccounts.add(account);
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
  }

  Widget _buildBankAccountTile(int index, Map<String, String> account) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey('${account['bank']}_${account['account']}_$index'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(10),
              onPressed: (_) => _showBankAccountDialog(index: index),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            SizedBox(width: 10),
            SlidableAction(
              borderRadius: BorderRadius.circular(10),
              onPressed: (_) {
                setState(() {
                  _bankAccounts.removeAt(index);
                });
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Eliminar',
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account['bank'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cuenta: ${account['account'] ?? ''}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _logoImage() {
    if (_businessLogoPath != null && File(_businessLogoPath!).existsSync()) {
      return FileImage(File(_businessLogoPath!));
    }
    return const AssetImage('assets/defaultProfileIMG.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Mantenimiento de negocio')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _showLogoPicker,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: _logoImage(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'Toca la foto para cambiar el logo del negocio',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _businessNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del negocio',
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Ingresa el nombre del negocio'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _businessAddressController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _businessPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              PhoneNumberTextInputFormatter(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Cuentas bancarias',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.w600,
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showBankAccountDialog(),
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.lightPrimary,
                                tooltip: 'Agregar cuenta bancaria',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_bankAccounts.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Aún no hay cuentas bancarias agregadas.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          else
                            Column(
                              children: _bankAccounts
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
                          // const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FilledButton(
                      onPressed: _saveBusinessInfo,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppColors.lightPrimary,
                      ),
                      child: const Text(
                        'Guardar información',
                        style: TextStyle(color: AppColors.lightSurface),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.length > 10 ? raw.substring(0, 10) : raw;

    String formatted;
    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      formatted =
          '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
