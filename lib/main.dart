// main.dart
import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/admin/admin_layout.dart'; // Point to Layout

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
        '/admin-dashboard': (context) =>
            const AdminLayout(), // Routes to Layout
      },
    );
  }
}
