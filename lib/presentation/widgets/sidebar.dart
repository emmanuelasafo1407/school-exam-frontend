import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/timetable_screen.dart';
import '../screens/admin/invigilator_approval_screen.dart';
import '../screens/admin/attendance_audit_screen.dart';
import '../screens/admin/admin_sub_screens.dart'; // Ensure you create this file with the skeletons

class Sidebar extends StatelessWidget {
  final Function(Widget) onPageSelected;

  const Sidebar({super.key, required this.onPageSelected});

  final List<Map<String, dynamic>> _menuItems = const [
    {
      'icon': Icons.dashboard,
      'title': 'Dashboard',
      'screen': AdminDashboardScreen(),
    },
    {
      'icon': Icons.people,
      'title': 'Class Members',
      'screen': UserManagementScreen(),
    },
    {
      'icon': Icons.table_chart,
      'title': 'Timetable',
      'screen': TimetableScreen(),
    },
    {
      'icon': Icons.admin_panel_settings,
      'title': 'Invigilator Approval',
      'screen': InvigilatorApprovalScreen(),
    },
    {
      'icon': Icons.check_circle,
      'title': 'Attendance',
      'screen': AttendanceAuditScreen(),
    },
    {
      'icon': Icons.analytics,
      'title': 'Analytics',
      'screen': AnalyticsScreen(), // Now linked to real skeleton
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Academic Year',
      'screen': AcademicYearScreen(), // Now linked to real skeleton
    },
    {
      'icon': Icons.settings,
      'title': 'Settings',
      'screen': SettingsScreen(), // Now linked to real skeleton
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF0A1929),
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
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  leading: Icon(item['icon'], color: Colors.white70),
                  title: Text(
                    item['title'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () => onPageSelected(item['screen']),
                );
              },
            ),
          ),
          // SECURE LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement your Auth logout logic here
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "SECURE LOGOUT",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
