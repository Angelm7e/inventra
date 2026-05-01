import 'package:flutter/material.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/screens/billing/billingScreen.dart';
import 'package:inventra/screens/profile/bussinesInfo/editBussinePhotoScreen.dart';
import 'package:inventra/screens/profile/bussinesInfo/business_invoice_settings_screen.dart';
import 'package:inventra/screens/profile/bussinesInfo/editBussinesInfoScreen.dart';
import 'package:inventra/screens/profile/category/categoryScreen.dart';
import 'package:inventra/screens/profile/exportData/exportDataScreen.dart';
import 'package:inventra/screens/profile/printers/addPrinterScreen.dart';
import 'package:inventra/screens/profile/printers/printerScreen.dart';
import 'package:inventra/screens/profile/profileScreen.dart';
import 'package:inventra/screens/quote/quoteScreen.dart';
import 'package:inventra/screens/sells/sellsScreen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  HomeScreen.routeName: (context) => const HomeScreen(),
  InventoryListScreen.routeName: (context) => const InventoryListScreen(),
  AddProductToInventoryScreen.routeName: (context) =>
      const AddProductToInventoryScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  EditBussinesPhotoScreen.routeName: (context) =>
      const EditBussinesPhotoScreen(),
  EditBussinesInfoScreen.routeName: (context) => const EditBussinesInfoScreen(),
  CategoryScreen.routeName: (context) => const CategoryScreen(),
  PrintersScreen.routeName: (context) => const PrintersScreen(),
  AddPrintersScreen.routeName: (context) => const AddPrintersScreen(),
  CatalogScreen.routeName: (context) => const CatalogScreen(),
  BillingScreen.routeName: (context) => const BillingScreen(),
  QuoteScreen.routeName: (context) => const QuoteScreen(),
  SellsScreen.routeName: (context) => const SellsScreen(),
  BusinessInvoiceSettingsScreen.routeName: (context) =>
      const BusinessInvoiceSettingsScreen(),
  ExportDataScreen.routeName: (context) => const ExportDataScreen(),

  // '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
};
