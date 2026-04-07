import 'package:flutter/material.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/screens/quote/quoteScreen.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size base = MediaQuery.of(context).size;
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/profilePicture.png',
                    width: base.width * 0.25,
                    // height: base.height * 0.11,
                    fit: BoxFit.cover, // 🔥 clave
                  ),
                ),
                Text("Bussines name", style: TextStyle(fontSize: 18)),
              ],
            ),
          ),

          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Catalog'),
            onTap: () {
              Navigator.pushNamed(context, CatalogScreen.routeName);
            },
          ),
          ListTile(
            title: Text('Cotización'),
            onTap: () {
              Navigator.pushNamed(context, QuoteScreen.routeName);
            },
          ),
          ListTile(
            title: Text('Ventas'),
            onTap: () {
              // Navigator.pushNamed(context, CatalogScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
