import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_client.dart';
import 'attendance_config_screen.dart';

class InvigilatorDashboard extends StatefulWidget {
  final Map<String, dynamic>
  userData; // 👈 Accept user data passed down from login
  final String token; // 👈 Accept the active Sanctum token string

  const InvigilatorDashboard({
    super.key,
    required this.userData,
    required this.token,
  });

  @override
  State<InvigilatorDashboard> createState() => _InvigilatorDashboardState();
}

class _InvigilatorDashboardState extends State<InvigilatorDashboard> {
  final ApiClient _apiClient =
      ApiClient(); // Instantiated to handle the logout API service call
  String _invigilatorName = "Invigilator";
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadSessionMetadata();
  }

  void _loadSessionMetadata() {
    setState(() {
      // Prioritize live constructor data passed down from the login response loop
      _invigilatorName = widget.userData['full_name'] ?? "Invigilator";
    });
  }

  // 👈 FIXED LOGOUT: Hits your backend route, clears local data storage, and pops routes safely
  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    // Show a circular processing loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Fire network request to revoke token on the Laravel backend database
      await _apiClient.logoutUser(widget.token);
    } catch (e) {
      debugPrint("Invigilator backend logout call failed: $e");
    }

    // 2. Clear out device cached records session footprints
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pop(context); // Close the progress circle dialog safely

    // 3. Flush view tree state history indices and bounce back to login layout
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // Make sure this matches your router's login route path name descriptor
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Invigilator session ended securely."),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invigilator Portal"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoggingOut
                ? null
                : _handleLogout, // Binds unified fixed controller method
          ),
        ],
      ),
      body: _isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header Block
                  Text(
                    "Welcome back,",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Text(
                    _invigilatorName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Card: Take Attendance Engine Entry Point
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AttendanceConfigScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Take Attendance",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Configure course and scan student entry tokens.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
