import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'student_verify_details_screen.dart';

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
        ),
      ),
    );

    // Process the result returned from the verification screen sheet option actions
    if (actionResult == "SCAN_ANOTHER") {
      setState(() => _isProcessingScan = false);
      _cameraController.start();
    } else if (actionResult == "DONE") {
      if (!mounted) return;
      // 👈 FIXED: Passes structural exit instruction up to the configuration screen pipeline
      Navigator.pop(context, "EXIT_SESSION");
      // Exit scanner screen completely and return back to home panel
    } else {
      // Handles native system back button pressed event
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
