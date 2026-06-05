import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/services/api_client.dart';
import 'session_summary_screen.dart';

class StudentVerifyDetailsScreen extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String hall;
  final String startTime;
  final String endTime;

  const StudentVerifyDetailsScreen({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.hall,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<StudentVerifyDetailsScreen> createState() =>
      _StudentVerifyDetailsScreenState();
}

class _StudentVerifyDetailsScreenState
    extends State<StudentVerifyDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _paperCodeController = TextEditingController();

  bool _isProcessingScan = false;
  Map<String, dynamic>? _scannedStudentData;
  String? _activeStudentId;

  void _onDetectBarcode(BarcodeCapture capture) async {
    if (_isProcessingScan || _scannedStudentData != null) return;

    final barcode = capture.barcodes.first;
    final String? scannedId = barcode.rawValue;

    if (scannedId == null || scannedId.isEmpty) return;

    setState(() {
      _isProcessingScan = true;
      _activeStudentId = scannedId;
    });

    _scannerController.stop();

    final response = await _apiClient.fetchStudentProfile(scannedId);

    if (response["statusCode"] == 200) {
      setState(() {
        _scannedStudentData = response["body"]["data"];
        _isProcessingScan = false;
      });
    } else {
      setState(() => _isProcessingScan = false);
      _showScanErrorSnackbar(
        response["body"]["message"] ?? "Student profile not found.",
      );
      _resumeScannerStream();
    }
  }

  Future<void> _submitAttendanceRecord() async {
    if (_paperCodeController.text.trim().isEmpty) {
      _showScanErrorSnackbar("Enter the student's exam booklet paper code!");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final int invigilatorId = prefs.getInt('user_id') ?? 1;

    // 👈 FIXED: Named properties explicitly mapped to clear compile errors on Line 79
    final result = await _apiClient.logStudentAttendance(
      studentId: _activeStudentId!,
      courseCode: widget.courseCode,
      courseName: widget.courseName,
      hall: widget.hall,
      startTime: widget.startTime,
      endTime: widget.endTime,
      invigilatorId: invigilatorId,
      paperCode: _paperCodeController.text.trim(),
    );

    if (!mounted) return;

    if (result["statusCode"] == 201) {
      _showLoopPromptDialog();
    } else {
      _showScanErrorSnackbar(
        result["body"]["message"] ?? "Failed to save attendance.",
      );
    }
  }

  void _showLoopPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Attendance Logged"),
          ],
        ),
        content: Text(
          "Attendance recorded successfully for ${_scannedStudentData?['name'] ?? 'Student'}.\nSelect next step:",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScannerStream();
            },
            child: const Text(
              "Scan Another Student",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSummaryReport();
            },
            child: const Text("Done / View Summary"),
          ),
        ],
      ),
    );
  }

  void _resumeScannerStream() {
    setState(() {
      _scannedStudentData = null;
      _activeStudentId = null;
      _paperCodeController.clear();
    });
    _scannerController.start();
  }

  void _navigateToSummaryReport() {
    _scannerController.dispose();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionSummaryScreen(
          courseCode: widget.courseCode,
          courseName: widget.courseName,
          hall: widget.hall,
        ),
      ),
    );
  }

  void _showScanErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _paperCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Entry Pass Cards"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: _scannedStudentData == null
                ? MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetectBarcode,
                  )
                : const Center(
                    child: Icon(Icons.fact_check, size: 80, color: Colors.blue),
                  ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: _isProcessingScan
                  ? const Center(child: CircularProgressIndicator())
                  : _scannedStudentData == null
                  ? const Center(
                      child: Text(
                        "Align a student's QR code pass to verify details.",
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _scannedStudentData!['name']
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Student ID: $_activeStudentId",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Program: ${_scannedStudentData!['program']} | Level: ${_scannedStudentData!['level']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(height: 24),
                          const Text(
                            "ASSIGN EXAM PAPER CODE",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _paperCodeController,
                            decoration: const InputDecoration(
                              labelText: "Booklet / Paper Code",
                              prefixIcon: Icon(Icons.edit_note),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitAttendanceRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Verify Attendance"),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
