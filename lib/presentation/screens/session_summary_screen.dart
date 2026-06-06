import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<dynamic> _checkedInStudentsList = [];

  @override
  void initState() {
    super.initState();
    _fetchSessionAnalyticsAndLedger();
  }

  Future<void> _fetchSessionAnalyticsAndLedger() async {
    setState(() => _isLoading = true);

    final analyticsResult = await _apiClient.fetchSessionAnalytics(
      widget.courseCode,
    );
    final ledgerResult = await _apiClient.fetchDetailedLedger(
      widget.courseCode,
    );

    if (!mounted) return;

    if (analyticsResult["statusCode"] == 200 &&
        ledgerResult["statusCode"] == 200) {
      setState(() {
        _summaryData = analyticsResult["body"]["summary"] ?? {};
        _checkedInStudentsList = ledgerResult["body"]["records"] ?? [];
        _errorMessage = null;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            analyticsResult["body"]["message"] ??
            "Failed to compile session analytics.";
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePaperSubmission(String studentId, int index) async {
    final result = await _apiClient.submitExamPaper(
      studentId: studentId,
      courseCode: widget.courseCode,
    );

    if (!mounted) return;

    if (result["statusCode"] == 200) {
      // Re-trigger global sync loop to immediately update the top metric squares and toggle button states
      await _fetchSessionAnalyticsAndLedger();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Exam script receipt confirmed successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["body"]["message"] ?? "Failed to save submission.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePdfExport() async {
    setState(() => _isExporting = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Compiling detailed ledger layout rows..."),
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
        dateGenerated: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        invigilatorName: responseBody["invigilator_name"] ?? "Akpor Norsor",
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
    // Calculates total dynamic script hand-ins present inside records list safely
    int totalSubmitted = _checkedInStudentsList
        .where(
          (s) =>
              s['paper_submitted'] == true ||
              s['paper_submitted'] == 1 ||
              s['paper_submitted'] == "1" ||
              s['paper_submitted'] == "true",
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Summary Report"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Sync Records",
            onPressed: _fetchSessionAnalyticsAndLedger,
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
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.grey.shade50,
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
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.courseCode,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.courseName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Hall: ${widget.hall}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              "EXPECTED",
                              _summaryData["total_allocated"].toString(),
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildMetricTile(
                              "PRESENT",
                              _summaryData["total_present"].toString(),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildMetricTile(
                              "SUBMITTED",
                              "$totalSubmitted",
                              Colors.orange.shade800,
                            ),
                          ), // Updates instantly
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildMetricTile(
                              "ABSENT",
                              _summaryData["total_absent"].toString(),
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "VERIFIED STUDENT LEDGER ROSTER (${_checkedInStudentsList.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: _checkedInStudentsList.isEmpty
                      ? const Center(
                          child: Text(
                            "No checkout records registered under this active session window.",
                          ),
                        )
                      : ListView.builder(
                          itemCount: _checkedInStudentsList.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          itemBuilder: (context, index) {
                            final student = _checkedInStudentsList[index];
                            final String studentId = student['index_number']
                                .toString();

                            // Evaluates safety bool definitions natively to map states accurately
                            final bool isSubmitted =
                                student['paper_submitted'] == true ||
                                student['paper_submitted'] == 1 ||
                                student['paper_submitted'] == "1" ||
                                student['paper_submitted'] == "true";

                            final String passportUrl =
                                "http://172.20.10.3:8000/storage/passports/passport_$studentId.jpg";

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          passportUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (student['student_name'] ?? 'N/A')
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "ID: $studentId | Shift: ${student['session']}",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "CODE: ${student['paper_code'] ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isSubmitted)
                                            Text(
                                              "SUBMITTED AT: ${student['time_submitted'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    ElevatedButton(
                                      onPressed: isSubmitted
                                          ? null
                                          : () => _handlePaperSubmission(
                                              studentId,
                                              index,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSubmitted
                                            ? Colors.grey.shade200
                                            : Colors.orange.shade700,
                                        foregroundColor: isSubmitted
                                            ? Colors.grey.shade500
                                            : Colors.white,
                                        elevation: isSubmitted ? 0 : 2,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        isSubmitted ? "Submitted" : "Submit",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMetricTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
