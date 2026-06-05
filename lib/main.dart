import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';

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
      // 1. Sets the default entry screen widget tree structure
      home: const LoginScreen(),

      // 2. 👈 FIXED: Added the named routes table so your logouts can safely clear the stack
      routes: {'/login': (context) => const LoginScreen()},
    );
  }
}
