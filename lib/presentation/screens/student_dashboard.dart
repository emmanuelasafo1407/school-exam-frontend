import 'package:flutter/material.dart';
import 'dart:async';
import 'student_qr_pass_screen.dart';
import 'student_timetable_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'notification_screen.dart'; // Ensure you import your LoginScreen to navigate back

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentProfile;
  final List<Map<String, dynamic>> rawSemesterExams;

  const StudentDashboard({
    super.key,
    required this.studentProfile,
    required this.rawSemesterExams,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Timer? _ticker;
  Map<String, dynamic>? _nextImmediateExam;
  bool _isExamLiveNow = false;

  @override
  void initState() {
    super.initState();
    _evaluateActiveExamSchedule();
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _evaluateActiveExamSchedule(),
    );
  }

  void _showEntryChecklist(BuildContext context) {
    if (_nextImmediateExam == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Final Pre-Exam Check"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Venue: ${_nextImmediateExam!['hall']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("Location: ${_nextImmediateExam!['floor_level']}"),
            const Divider(),
            const Text("1. Checked for your ID Card?"),
            const Text("2. Checked for your QR Code paper?"),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeText(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
  Widget _buildExamPrepReminder() {
    return Card(
      color: Colors.amber.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ IMPORTANT: Before Leaving",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.badge, color: Colors.blue),
              title: Text("Carry your Student ID Card"),
              visualDensity: VisualDensity.compact,
            ),
            const ListTile(
              leading: Icon(Icons.qr_code, color: Colors.blue),
              title: Text("Carry your Printed Semester QR Code"),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _evaluateActiveExamSchedule() {
    final now = DateTime.now();
    Map<String, dynamic>? targetedExam;
    bool liveStatus = false;

    List<Map<String, dynamic>> sorted = List.from(widget.rawSemesterExams);
    sorted.sort(
      (a, b) => DateTime.parse(
        a['start_time'],
      ).compareTo(DateTime.parse(b['start_time'])),
    );

    for (var exam in sorted) {
      final start = DateTime.parse(exam['start_time']);
      final end = DateTime.parse(exam['end_time']);
      if (now.isAfter(start) && now.isBefore(end)) {
        targetedExam = exam;
        liveStatus = true;
        break;
      }
      if (now.isBefore(start)) {
        targetedExam = exam;
        liveStatus = false;
        break;
      }
    }
    if (mounted) {
      setState(() {
        _nextImmediateExam = targetedExam;
        _isExamLiveNow = liveStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String studentName = widget.studentProfile['name'] ?? 'Student';
    final String indexNumber = widget.studentProfile['index_number'] ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Student Portal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ), // Notification Icon
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Square Profile Picture
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2.5),
                    color: Colors.white24,
                    image: widget.studentProfile['passport_picture'] != null
                        ? DecorationImage(
                            image: NetworkImage(
                              widget.studentProfile['passport_picture']
                                  .replaceAll("localhost", "172.20.10.3"),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.studentProfile['passport_picture'] == null
                      ? const Icon(Icons.person, size: 36, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back,",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ID: $indexNumber | Level ${widget.studentProfile['level'] ?? '300'}",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CURRENT PAPERS WINDOW",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildExamPrepReminder(),
                  _buildLargeText(
                    _isExamLiveNow ? "LIVE NOW" : "NEXT EXAM",
                    _nextImmediateExam != null
                        ? "${_nextImmediateExam!['course_code']} - ${_nextImmediateExam!['course_name']}"
                        : "No upcoming exams",
                  ),

                  _nextImmediateExam == null
                      ? _buildEmptyStateCard()
                      : Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: _isExamLiveNow
                                  ? Colors.red.shade200
                                  : Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nextImmediateExam!['course_code'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  _nextImmediateExam!['course_name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(height: 24),
                                _buildDetailRow(
                                  Icons.location_on,
                                  "Venue Hall",
                                  _nextImmediateExam!['hall'] ?? 'N/A',
                                ),
                                _buildDetailRow(
                                  Icons.layers,
                                  "Floor Level",
                                  _nextImmediateExam!['floor_level'] ??
                                      'Ground Floor',
                                ),
                                _buildDetailRow(
                                  Icons.event_seat,
                                  "Seating Info",
                                  _nextImmediateExam!['seating_info'] ??
                                      'Check notice board',
                                ),

                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final url = _nextImmediateExam!['map_link'];
                                    if (url != null &&
                                        await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text("View Hall Direction Map"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),
                  const Text(
                    "PORTAL ACCESS LINKS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  // Add this to your main Build or as a button in the Card
                  ElevatedButton(
                    onPressed: () {
                      if (_nextImmediateExam != null) {
                        // If there is an exam, show the real checklist with Venue/Floor data
                        _showEntryChecklist(context);
                      } else {
                        // If no exam, show a polite "No active papers" snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No upcoming papers detected. Enjoy your break!",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text("Show Entry Checklist"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuCard(
                          context,
                          "Full Timetable",
                          Icons.table_chart,
                          Colors.purple,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentTimetableScreen(
                                semesterExams: widget.rawSemesterExams,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMenuCard(
                          context,
                          "Gate Token Pass",
                          Icons.qr_code_scanner,
                          Colors.teal,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentQrPassScreen(
                                studentProfile: widget.studentProfile,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(color: Colors.grey.shade600)),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildMenuCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback action,
  ) => InkWell(
    onTap: action,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  Widget _buildEmptyStateCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: const Column(
      children: [
        Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
        SizedBox(height: 12),
        Text("All Cleared!", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
