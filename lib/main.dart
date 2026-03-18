import 'package:flutter/material.dart';
import 'screens/expense_home_page.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff3f4f8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3d7dff)),
      ),
      home: const ExpenseHomePage(),
    );
  }
}
