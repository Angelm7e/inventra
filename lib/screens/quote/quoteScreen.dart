import 'package:flutter/material.dart';
import 'package:inventra/widgets/bottomNavBar.dart';

class QuotesCreen extends StatefulWidget {
  const QuotesCreen({super.key});

  static const String routeName = '/quoteScreen';

  @override
  State<QuotesCreen> createState() => _QuotesCreenState();
}

class _QuotesCreenState extends State<QuotesCreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotes')),
      body: const Center(child: Text('Quotes Screen')),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
