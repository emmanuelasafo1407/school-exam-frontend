import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';
// 1. IMPORT YOUR NEW ADMIN SCREEN
import 'presentation/screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam Attendance System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // 2. REGISTER THE ROUTE HERE
        '/admin-dashboard': (context) => AdminDashboardScreen(),
      },
    );
  }
}
