// lib/presentation/screens/admin/admin_layout.dart
import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import '../../widgets/sidebar.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  // 1. Initialize with the Dashboard screen
  Widget _activePage = const AdminDashboardScreen();

  // 2. This function changes the content
  void _changePage(Widget newPage) {
    setState(() {
      _activePage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar is fixed here, it never moves/reloads
          Sidebar(onPageSelected: _changePage),

          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(24),
              child: _activePage, // Only this part updates
            ),
          ),
        ],
      ),
    );
  }
}
