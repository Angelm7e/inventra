import 'package:flutter/material.dart';
import 'package:inventra/screens/catalog/catalogScreen.dart';
import 'package:inventra/widgets/bottomNavBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: SizedBox(), title: const Text('Home Screen')),
      body: Column(
        children: [
          Text('Welcome to the Home Screen!'),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, CatalogScreen.routeName);
            },
            child: Text('Go to Catalog'),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        // onTabSelected: (index) {},
      ),
    );
  }
}
