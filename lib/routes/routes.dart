import 'package:flutter/material.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/screens/quote/quoteScreen.dart';
import 'package:inventra/screens/settingScreen/bussinesInfo/editBussinePhotoScreen.dart';
import 'package:inventra/screens/settingScreen/bussinesInfo/editBussinesInfoScreen.dart';
import 'package:inventra/screens/settingScreen/category/addCategoryScreen.dart';
import 'package:inventra/screens/settingScreen/category/categoryScreen.dart';
import 'package:inventra/screens/settingScreen/printers/addPrinterScreen.dart';
import 'package:inventra/screens/settingScreen/printers/printerScreen.dart';
import 'package:inventra/screens/settingScreen/settingScreen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  HomeScreen.routeName: (context) => const HomeScreen(),
  InventoryListScreen.routeName: (context) => const InventoryListScreen(),
  AddProductToInventoryScreen.routeName: (context) =>
      const AddProductToInventoryScreen(),
  SettingScreen.routeName: (context) => const SettingScreen(),
  QuotesCreen.routeName: (context) => const QuotesCreen(),
  EditBussinesPhotoScreen.routeName: (context) =>
      const EditBussinesPhotoScreen(),
  EditBussinesInfoScreen.routeName: (context) => const EditBussinesInfoScreen(),
  CategoryScreen.routeName: (context) => const CategoryScreen(),
  AddCategoryScreen.routeName: (context) => const AddCategoryScreen(),
  PrintersScreen.routeName: (context) => const PrintersScreen(),
  AddPrintersScreen.routeName: (context) => const AddPrintersScreen(),

  // '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
};
