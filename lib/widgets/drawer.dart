import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventra/screens/billing/billingScreen.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/screens/profile/profileScreen.dart';
import 'package:inventra/screens/quote/quoteScreen.dart';
import 'package:inventra/screens/sells/sellsScreen.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/utils/colors.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: DatabaseHelper.instance.getBusinessSettings(),
              builder: (context, snapshot) {
                final settings = snapshot.data ?? {};
                final businessName =
                    settings['name'] as String? ?? 'Nombre del negocio';
                final logoPath = settings['logo_path'] as String?;
                final imageProvider =
                    (logoPath != null && File(logoPath).existsSync())
                    ? FileImage(File(logoPath)) as ImageProvider
                    : const AssetImage('assets/defaultProfileIMG.png');

                return DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageProvider,
                      ),
                      Text(
                        businessName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Inicio',
                    routeName: HomeScreen.routeName,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.store_outlined,
                    label: 'Catálogo',
                    routeName: CatalogScreen.routeName,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    label: 'Facturar',
                    routeName: BillingScreen.routeName,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventario',
                    routeName: InventoryListScreen.routeName,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.request_quote_outlined,
                    label: 'Cotizaciones',
                    routeName: QuoteScreen.routeName,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.sell_outlined,
                    label: 'Ventas',
                    routeName: SellsScreen.routeName,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    routeName: ProfileScreen.routeName,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventra',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Creada por Angel encarnacion',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'contacto 829-969-3877',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.lightPrimary),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
