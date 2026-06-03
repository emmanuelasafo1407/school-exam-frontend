import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'student_verify_details_screen.dart';
import 'session_summary_screen.dart';

class ScannerViewScreen extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String hall;

  const ScannerViewScreen({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.hall,
  });

  @override
  State<ScannerViewScreen> createState() => _ScannerViewScreenState();
}

class _ScannerViewScreenState extends State<ScannerViewScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessingScan = false;

  void _handleQrVerification(String studentId) async {
    setState(() => _isProcessingScan = true);
    _cameraController.stop(); // Stop scanning to avoid duplicate triggers

    // Route cleanly to the full manual identity check profile verification page
    final actionResult = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => StudentVerifyDetailsScreen(
          studentId: studentId,
          courseCode: widget.courseCode,
          courseName: widget.courseName,
          hall: widget.hall,
        ),
      ),
    );

    if (!mounted) return;

    // Process the result returned from the verification screen sheet option actions
    if (actionResult == "SCAN_ANOTHER") {
      setState(() => _isProcessingScan = false);
      _cameraController.start();
    } else if (actionResult == "DONE") {
      // 👈 FIXED: Instead of popping out blindly, push replacement to the Session Summary metrics screen
      final exitStatus = await Navigator.pushReplacement<String, dynamic>(
        context,
        MaterialPageRoute(
          builder: (context) => SessionSummaryScreen(
            courseCode: widget.courseCode,
            courseName: widget.courseName,
            hall: widget.hall,
          ),
        ),
      );

      // If the summary screen passes back the terminal exit flag, pass it up to close the configuration stack
      if (exitStatus == "EXIT_SESSION" && mounted) {
        Navigator.pop(context, "EXIT_SESSION");
      }
    } else {
      // Handles native system back button pressed event during the verification phase
      setState(() => _isProcessingScan = false);
      _cameraController.start();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scanning: ${widget.courseCode}")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (_isProcessingScan) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQrVerification(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Viewfinder targeting frame overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
