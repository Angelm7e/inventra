import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventra/routes/routes.dart';
import 'package:inventra/screens/homeScreen/homeScreen.dart';
import 'package:inventra/theme/theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      initialRoute: HomeScreen.routeName,
      routes: appRoutes,
    );
  }
}
