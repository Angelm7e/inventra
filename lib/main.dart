import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventra/provider/categoryProvider.dart';
import 'package:inventra/provider/printerProvider.dart';
import 'package:inventra/provider/productProvider.dart';
import 'package:inventra/provider/billing_provider.dart';
import 'package:inventra/provider/quoteProvider.dart';
import 'package:inventra/routes/routes.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/services/categoryService.dart';
import 'package:inventra/services/dataBaseHelper.dart';
import 'package:inventra/services/printerService.dart';
import 'package:inventra/services/productService.dart';
import 'package:inventra/theme/theme.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, //
      statusBarBrightness: Brightness.light, // iOS

      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark, //x
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(ProductService()),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(CategoryService()),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(CategoryService()),
        ),
        ChangeNotifierProvider<QuoteProvider>(
          create: (context) => QuoteProvider(),
        ),
        ChangeNotifierProvider<BillingProvider>(
          create: (context) => BillingProvider(),
        ),
        ChangeNotifierProvider<PrinterProvider>(
          create: (context) => PrinterProvider(PrinterService()),
        ),
        // ChangeNotifierProvider<AuthProvider>(
        //   create: (context) => AuthProvider(AuthService()),
        // ),
      ],
      child: SafeArea(
        top: false,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          initialRoute: HomeScreen.routeName,
          routes: appRoutes,
        ),
      ),
    );
  }
}
