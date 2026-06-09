import 'package:flutter/material.dart';
import '../../../data/services/api_client.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _apiClient.fetchExamSessions();
    setState(() => _sessions = sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Manage Timetable",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Add Exam Session"),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              return Card(
                child: ListTile(
                  title: Text(
                    "${session['course_code']} - ${session['course_name']}",
                  ),
                  subtitle: Text(
                    "Date: ${session['exam_date']} | Venue: ${session['venue']}",
                  ),
                  trailing: Switch(
                    value: session['is_active'] == 1,
                    onChanged: (val) async {
                      await _apiClient.toggleSessionStatus(session['id'], val);
                      _loadSessions();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
