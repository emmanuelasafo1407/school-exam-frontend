import 'package:flutter/material.dart';
import '../../../data/services/api_client.dart';
import '../../widgets/csv_upload_button.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _apiClient.getAdminStats();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Systems Command Center",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // KPI CARDS ROW
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final data =
                  snapshot.data ??
                  {
                    'total_students': 0,
                    'active_sessions': 0,
                    'secure_bindings': 0,
                  };
              return Row(
                children: [
                  _buildKpiCard(
                    "Enrolled Students",
                    data['total_students'].toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  _buildKpiCard(
                    "Active Sessions",
                    data['active_sessions'].toString(),
                    Icons.flash_on,
                    Colors.orange,
                  ),
                  const SizedBox(width: 20),
                  _buildKpiCard(
                    "Secure Bindings",
                    data['secure_bindings'].toString(),
                    Icons.lock,
                    Colors.green,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // LOWER SECTION: Quick Actions + CSV Upload
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Quick Actions
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1929),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "InvigiloEMS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "High-integrity attendance tracking",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      CsvUploadButton(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right: Placeholder for Recent Activity
              Expanded(
                flex: 2,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text("Recent Check-ins Stream Placeholder"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Icon(icon, size: 28, color: color),
          ],
        ),
      ),
    );
  }
}
