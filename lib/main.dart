import 'package:flutter/material.dart';
import 'package:projeto/pages/login_page.dart';
import 'pages/product_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFBF0603)),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

