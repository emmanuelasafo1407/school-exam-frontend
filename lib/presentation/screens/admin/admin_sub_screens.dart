import 'package:flutter/material.dart';

// 1. Timetable: We already have this, but you need to ensure the CRUD works.
// 2. Class Members: You already have this (UserManagementScreen).
// 3. Analytics
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      _buildModuleSkeleton("Analytics Dashboard", Icons.analytics);
}

// 4. Academic Year
class AcademicYearScreen extends StatelessWidget {
  const AcademicYearScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      _buildModuleSkeleton("Academic Year Management", Icons.calendar_today);
}

// 5. Settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      _buildModuleSkeleton("System Settings", Icons.settings);
}

Widget _buildModuleSkeleton(String title, IconData icon) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("Under development for full integration"),
        ],
      ),
    ),
  );
}
