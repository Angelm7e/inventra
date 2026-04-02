import 'package:flutter/material.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/screens/inventory/addProductToInventoryScreen.dart';
import 'package:inventra/screens/inventory/inventoryListScreen.dart';
import 'package:inventra/screens/settingScreen/settingScreen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  HomeScreen.routeName: (context) => const HomeScreen(),
  InventoryListScreen.routeName: (context) => const InventoryListScreen(),
  AddProductToInventoryScreen.routeName: (context) =>
      const AddProductToInventoryScreen(),
  SettingScreen.routeName: (context) => const SettingScreen(),

  // '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
  // '/settings': (context) => const SettingsPage(),
  // '/profile': (context) => const ProfilePage(),
};
