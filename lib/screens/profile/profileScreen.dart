import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventra/screens/profile/bussinesInfo/editBussinesInfoScreen.dart';
import 'package:inventra/screens/profile/bussinesInfo/business_invoice_settings_screen.dart';
import 'package:inventra/screens/profile/category/categoryScreen.dart';
import 'package:inventra/screens/profile/exportData/exportDataScreen.dart';
import 'package:inventra/screens/profile/printers/printerScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/customSettingsButtom.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profileScreen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _settingsFuture = DatabaseHelper.instance.getBusinessSettings();
  }

  Future<void> _reloadSettings() async {
    setState(() {
      _loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size base = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(leading: SizedBox(), title: const Text('Configuraciones')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _onProfilePictureTapped(context);
                },
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _settingsFuture,
                  builder: (context, snapshot) {
                    final settings = snapshot.data ?? {};
                    final logoPath = settings['logo_path'] as String?;
                    final imageProvider =
                        (logoPath != null && File(logoPath).existsSync())
                        ? FileImage(File(logoPath)) as ImageProvider
                        : const AssetImage('assets/defaultProfileIMG.png');
                    return CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.grey,
                      backgroundImage: imageProvider,
                    );
                  },
                ),
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: _settingsFuture,
                builder: (context, snapshot) {
                  final settings = snapshot.data ?? {};
                  return buildPersonalInfo(base, settings);
                },
              ),
              SizedBox(height: base.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    CustomSettingsButtom(
                      label: "Editar informacion",
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          EditBussinesInfoScreen.routeName,
                        );
                        await _reloadSettings();
                      },
                      icon: Icons.edit,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CustomSettingsButtom(
                        label: "Editar Categorias",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            CategoryScreen.routeName,
                          );
                        },
                        icon: Icons.category,
                      ),
                    ),
                    CustomSettingsButtom(
                      label: "Impresoras",
                      onTap: () {
                        Navigator.pushNamed(context, PrintersScreen.routeName);
                      },
                      icon: Icons.print,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CustomSettingsButtom(
                        label: "Editar factura",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            BusinessInvoiceSettingsScreen.routeName,
                          );
                        },
                        icon: Icons.receipt_long,
                      ),
                    ),
                    CustomSettingsButtom(
                      label: "Exportar datos",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ExportDataScreen.routeName,
                        );
                      },
                      icon: Icons.file_download,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        // onTabSelected: (index) {},
      ),
    );
  }

  Widget buildPersonalInfo(Size base, Map<String, dynamic> settings) {
    final businessName = settings['name'] as String? ?? 'Nombre del negocio';
    final businessPhone =
        settings['phone'] as String? ?? 'Teléfono no registrado';
    final businessAddress =
        settings['address'] as String? ?? 'Dirección no registrada';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            businessName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(businessPhone, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(businessAddress, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _onProfilePictureTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar información del negocio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    EditBussinesInfoScreen.routeName,
                  ).then((_) => _reloadSettings());
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cerrar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
