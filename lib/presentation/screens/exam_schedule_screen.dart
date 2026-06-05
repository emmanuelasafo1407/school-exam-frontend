import 'package:flutter/material.dart';

class ExamScheduleScreen extends StatelessWidget {
  const ExamScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static mockup data listing for semester exam timetable structure
    final List<Map<String, String>> exams = [
      {
        'code': 'BCE 302',
        'name': 'Computer Architecture',
        'location': 'Engineering Block Rm 4',
        'time': '2026-06-15 | 09:00 AM - 12:00 PM',
      },
      {
        'code': 'BCE 304',
        'name': 'Embedded Systems Engineering',
        'location': 'Main Auditorium Hall B',
        'time': '2026-06-18 | 01:30 PM - 04:30 PM',
      },
      {
        'code': 'MATH 101',
        'name': 'Engineering Mathematics',
        'location': 'Examination Hall G6',
        'time': '2026-06-22 | 09:00 AM - 12:00 PM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Exam Timetable"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          return Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exam['code']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam['location']!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          exam['time']!,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
