import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/services/api_client.dart';
import 'session_summary_screen.dart';

class StudentVerifyDetailsScreen extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String lecturerName;
  final String hall;
  final String startTime;
  final String endTime;

  const StudentVerifyDetailsScreen({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.lecturerName,
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
  late MobileScannerController _scannerController;
  final TextEditingController _paperCodeController = TextEditingController();

  bool _isLoadingProfile = false;
  bool _isSubmitting = false;
  String? _activeStudentId;
  Map<String, dynamic>? _studentProfileData;
  bool _canScan = true;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: true,
    );
  }

  void _onDetectBarcode(BarcodeCapture capture) async {
    if (!_canScan ||
        _isLoadingProfile ||
        _isSubmitting ||
        _activeStudentId != null)
      return;

    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;
    final String? scannedId = barcode.rawValue?.trim();

    if (scannedId == null || scannedId.length < 5) return;

    setState(() {
      _canScan = false;
      _activeStudentId = scannedId;
      _isLoadingProfile = true;
    });

    final response = await _apiClient.fetchVerifiedStudentProfile(scannedId);

    if (!mounted) return;

    if (response["statusCode"] == 200) {
      setState(() {
        _studentProfileData = response["body"]["data"];
        _isLoadingProfile = false;
      });
    } else {
      setState(() {
        _isLoadingProfile = false;
        _activeStudentId = null;
        _canScan = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["body"]["message"] ??
                "Student record missing from database.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitAttendanceRecord() async {
    if (_paperCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter the student's exam booklet paper code!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final int invigilatorId = prefs.getInt('user_id') ?? 1;

    final result = await _apiClient.logStudentAttendance(
      studentId: _activeStudentId!,
      courseCode: widget.courseCode,
      courseName: widget.courseName,
      lecturerName: widget.lecturerName,
      hall: widget.hall,
      startTime: widget.startTime,
      endTime: widget.endTime,
      invigilatorId: invigilatorId,
      paperCode: _paperCodeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result["statusCode"] == 201) {
      _showSuccessPromptDialog();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text("Attendance Duplicate"),
            ],
          ),
          content: Text(
            result["body"]["message"] ??
                "This student has already checked into this exam session room.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss dialog
                _exitToSummary(); // Cleanly exit to summary screen
              },
              child: const Text(
                "Done / Close",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resumeScannerStream();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Next Scan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccessPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Verification Complete"),
          ],
        ),
        content: Text(
          "Attendance recorded successfully for ${_studentProfileData?['name'] ?? _activeStudentId}.\nChoose next step:",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss dialog
              _exitToSummary(); // Cleanly exit to summary screen
            },
            child: const Text(
              "Done / Close",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScannerStream();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              "Scan Another Student",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeScannerStream() {
    setState(() {
      _activeStudentId = null;
      _studentProfileData = null;
      _paperCodeController.clear();
      _canScan = true;
    });
  }

  void _exitToSummary() {
    _scannerController.dispose(); // Release camera resources immediately
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

  @override
  void dispose() {
    _scannerController.dispose();
    _paperCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? rawPicPath = _studentProfileData?['passport_picture'];
    String passportUrl = rawPicPath != null
        ? rawPicPath.replaceAll("localhost", "172.20.10.3")
        : "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Entry Pass Cards"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _exitToSummary,
        ),
        actions: [
          TextButton.icon(
            onPressed: _exitToSummary,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              "Finish",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _activeStudentId == null
                ? MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetectBarcode,
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Colors.blue,
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : _activeStudentId == null
                  ? const Center(
                      child: Text(
                        "Align a student's QR pass card inside the viewfinder to verify entry credentials.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade700,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: passportUrl.isNotEmpty
                                    ? Image.network(
                                        passportUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            (_studentProfileData?['name'] ?? 'N/A')
                                .toString()
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                _buildProfileDetailRow(
                                  "Student ID",
                                  _activeStudentId ?? 'N/A',
                                  Colors.blue.shade900,
                                  isBold: true,
                                ),
                                const Divider(),
                                _buildProfileDetailRow(
                                  "Program",
                                  (_studentProfileData?['program'] ?? 'N/A')
                                      .toString()
                                      .toUpperCase(),
                                  Colors.black87,
                                ),
                                const Divider(),
                                _buildProfileDetailRow(
                                  "Level",
                                  "Level ${_studentProfileData?['level'] ?? 'N/A'}",
                                  Colors.black87,
                                ),
                                const Divider(),
                                _buildProfileDetailRow(
                                  "Session Shift",
                                  (_studentProfileData?['session'] ?? 'Morning')
                                      .toString()
                                      .toUpperCase(),
                                  Colors.purple.shade700,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "ASSIGN EXAM PAPER BOOKLET CODE",
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
                              labelText: "Exams Paper / Booklet Code",
                              prefixIcon: Icon(Icons.edit_note),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : _submitAttendanceRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Check Attendance",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  Widget _buildProfileDetailRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
