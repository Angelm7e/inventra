import 'package:flutter/material.dart';
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
      body: const Center(child: Text('Welcome to the Home Screen!')),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        // onTabSelected: (index) {},
      ),
    );
  }
}
