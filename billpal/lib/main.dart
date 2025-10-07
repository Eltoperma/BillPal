import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const BillPalApp());
}

class BillPalApp extends StatelessWidget {
  const BillPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}
