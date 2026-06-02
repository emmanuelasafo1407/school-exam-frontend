import 'package:flutter/material.dart';
import '../../data/services/api_client.dart';

class StudentVerifyDetailsScreen extends StatefulWidget {
  final String studentId;
  final String courseCode;

  const StudentVerifyDetailsScreen({
    super.key,
    required this.studentId,
    required this.courseCode,
  });

  @override
  State<StudentVerifyDetailsScreen> createState() =>
      _StudentVerifyDetailsScreenState();
}

class _StudentVerifyDetailsScreenState
    extends State<StudentVerifyDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Real data state values map
  late Map<String, dynamic> _studentData;

  @override
  void initState() {
    super.initState();
    _loadLiveStudentProfile();
  }

  Future<void> _loadLiveStudentProfile() async {
    final result = await _apiClient.fetchStudentProfile(widget.studentId);

    if (!mounted) return;

    if (result["statusCode"] == 200) {
      final responseBody = result["body"];
      setState(() {
        _studentData = responseBody["data"];
        // Rewrite localhost path prefix to point directly at your PC IP address
        if (_studentData["passport_picture"] != null) {
          _studentData["passport_picture"] = _studentData["passport_picture"]
              .toString()
              .replaceAll("localhost", "172.20.10.3");
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result["body"]["message"] ?? "Failed to load profile.";
        _isLoading = false;
      });
    }
  }

  void _confirmAttendance() {
    setState(() => _isSaving = true);

    // Attendance transaction database log placeholder logic goes here

    setState(() => _isSaving = false);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Attendance Confirmed Manually",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${_studentData['name']} has been marked PRESENT for ${widget.courseCode}.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close sheet
                Navigator.pop(
                  context,
                  "SCAN_ANOTHER",
                ); // Ask camera view to re-arm sensor loop
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                "Take Another Scan",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              // 👈 FIXED: Direct instruction command to drop out back to the main dashboard panel
              onPressed: () {
                Navigator.pop(context); // Close sheet
                Navigator.pop(
                  context,
                  "DONE",
                ); // Send final close code payload up to scanner view
              },
              icon: const Icon(Icons.done_all),
              label: const Text(
                "Done / Close Session",
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Identity Verification"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _studentData["passport_picture"] != null
                            ? Image.network(
                                _studentData["passport_picture"], // 👈 DYNAMIC: Live network photo file
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.account_box,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                              )
                            : const Icon(
                                Icons.account_box,
                                size: 100,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Verify Student Details Below:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(),
                  _buildDetailRow(
                    "FULL NAME",
                    _studentData["name"]!,
                    isHighlight: true,
                  ),
                  _buildDetailRow(
                    "STUDENT ID",
                    _studentData["student_id_number"]!,
                  ),
                  _buildDetailRow("PROGRAM", _studentData["program"]!),
                  _buildDetailRow("DEPARTMENT", _studentData["department"]!),
                  _buildDetailRow(
                    "LEVEL / ACADEMIC TIER",
                    "Level ${_studentData['level']}",
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _confirmAttendance,
                    icon: const Icon(Icons.how_to_reg, size: 24),
                    label: const Text(
                      "Confirm & Log Attendance",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 15,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? Colors.blue.shade900 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
