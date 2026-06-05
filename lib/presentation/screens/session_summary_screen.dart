import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_client.dart';
import '../../data/services/pdf_generator_service.dart';

class SessionSummaryScreen extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String hall;

  const SessionSummaryScreen({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.hall,
  });

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  bool _isExporting = false;
  String? _errorMessage;

  Map<String, dynamic> _summaryData = {};

  @override
  void initState() {
    super.initState();
    _fetchSessionAnalytics();
  }

  Future<void> _fetchSessionAnalytics() async {
    final result = await _apiClient.fetchSessionAnalytics(widget.courseCode);

    if (!mounted) return;

    if (result["statusCode"] == 200) {
      setState(() {
        _summaryData = result["body"]["summary"];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            result["body"]["message"] ?? "Failed to compile session analytics.";
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePdfExport() async {
    setState(() => _isExporting = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fetching detailed records layout database rows..."),
        duration: Duration(seconds: 1),
      ),
    );

    final result = await _apiClient.fetchDetailedLedger(widget.courseCode);

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (result["statusCode"] == 200) {
      final responseBody = result["body"];

      await PdfGeneratorService.generateAndPrintLedger(
        courseCode: widget.courseCode,
        courseName: widget.courseName,
        hall: widget.hall,
        dateGenerated: responseBody["date_generated"] ?? "N/A",
        invigilatorName: responseBody["invigilator_name"] ?? "N/A",
        signaturePicture: responseBody["signature_picture"],
        records: responseBody["records"] ?? [],
      );
    } else {
      String failMsg =
          result["body"]["message"] ??
          "Failed to compile document ledger dataset.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Summary Report"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout System",
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.courseName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Hall: ${widget.hall}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "ATTENDANCE METRICS BREAKDOWN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          "TOTAL EXPECTED",
                          _summaryData["total_allocated"].toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          "PRESENT",
                          _summaryData["total_present"].toString(),
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          "ABSENT",
                          _summaryData["total_absent"].toString(),
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          "ATTENDANCE RATE",
                          "${_summaryData["attendance_rate_percentage"]}%",
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handlePdfExport,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(
                      _isExporting
                          ? "Compiling Ledger Document..."
                          : "Export Official Attendance PDF",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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

  Widget _buildMetricTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
