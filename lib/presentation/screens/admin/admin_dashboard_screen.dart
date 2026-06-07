import 'package:flutter/material.dart';
import 'admin_layout.dart';
import '../../../data/services/api_client.dart'; // Ensure this points to your ApiClient

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
    // Trigger the API call when the screen initializes
    _statsFuture = _apiClient.getAdminStats();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Systems Command Center",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // KPI CARDS ROW with FutureBuilder
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text("Error loading stats: ${snapshot.error}");
              }

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
                  ),
                  const SizedBox(width: 20),
                  _buildKpiCard(
                    "Active Sessions",
                    data['active_sessions'].toString(),
                    Icons.flash_on,
                  ),
                  const SizedBox(width: 20),
                  _buildKpiCard(
                    "Secure Bindings",
                    data['secure_bindings'].toString(),
                    Icons.lock,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Icon(icon, size: 30, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
