import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // THE SIDEBAR
          Container(
            width: 250,
            color: const Color(0xFF0A1929), // Dark blue like your friend's
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "InvigiloEMS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildNavItem(Icons.dashboard, "Dashboard"),
                _buildNavItem(Icons.table_chart, "Timetable"),
                _buildNavItem(Icons.people, "Class Members"),
                _buildNavItem(Icons.check_circle, "Attendance"),
                _buildNavItem(Icons.analytics, "Analytics"),
                _buildNavItem(Icons.calendar_today, "Academic Year"),
                _buildNavItem(Icons.settings, "Settings"),
              ],
            ),
          ),
          // MAIN CONTENT AREA
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () {},
    );
  }
}
