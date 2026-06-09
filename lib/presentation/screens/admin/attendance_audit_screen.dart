import 'package:flutter/material.dart';
import '../../../data/services/api_client.dart';

class AttendanceAuditScreen extends StatefulWidget {
  const AttendanceAuditScreen({super.key});

  @override
  State<AttendanceAuditScreen> createState() => _AttendanceAuditScreenState();
}

class _AttendanceAuditScreenState extends State<AttendanceAuditScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _apiClient.fetchAllAttendanceLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      // If API fails, you can leave _logs empty or add error handling
      setState(() => _isLoading = false);
      debugPrint("Error fetching logs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Attendance Audit"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLogs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text("No attendance logs found."))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                // Accessing nested data based on Laravel's 'with()' relationship
                // Adjust keys 'full_name' or 'student' based on your actual API response
                final studentName = log['student']?['full_name'] ?? 'Unknown';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.blue,
                    ),
                    title: Text("Student: $studentName"),
                    subtitle: Text(
                      "Hall: ${log['hall'] ?? 'N/A'} | Time: ${log['scanned_at'] ?? 'N/A'}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
