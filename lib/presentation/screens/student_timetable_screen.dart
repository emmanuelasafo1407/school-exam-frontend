import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentTimetableScreen extends StatelessWidget {
  final List<dynamic> semesterExams;

  const StudentTimetableScreen({super.key, required this.semesterExams});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    List<dynamic> sortedExams = List.from(semesterExams);
    sortedExams.sort(
      (a, b) => DateTime.parse(
        a['start_time'],
      ).compareTo(DateTime.parse(b['start_time'])),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Your Exam Timetable",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: sortedExams.isEmpty
          ? const Center(
              child: Text(
                "No official program papers registered for this term.",
              ),
            )
          : ListView.builder(
              itemCount: sortedExams.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final exam = sortedExams[index];
                final start = DateTime.parse(exam['start_time']);
                final end = DateTime.parse(exam['end_time']);

                final bool isPast = now.isAfter(end);
                final bool isOngoing = now.isAfter(start) && now.isBefore(end);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      // 👈 FIXED
                      color: isOngoing
                          ? Colors.red.shade300
                          : isPast
                          ? Colors.grey.shade200
                          : Colors.blue.shade100,
                      width: isOngoing ? 2 : 1,
                    ),
                  ),
                  color: isPast ? Colors.grey.shade100 : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPast
                                ? Colors.grey.shade300
                                : isOngoing
                                ? Colors.red.shade100
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exam['course_code'] ?? 'N/A',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isPast
                                  ? Colors.grey.shade700
                                  : isOngoing
                                  ? Colors.red.shade900
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exam['course_name'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isPast
                                            ? Colors.grey.shade600
                                            : Colors.black87, // 👈 FIXED TYPO
                                        decoration: isPast
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isOngoing)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "WRITING",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else if (isPast)
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.grey,
                                          size: 14,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "Done",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "UPCOMING",
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exam['hall'] ?? 'N/A',
                                style: TextStyle(
                                  color: isPast ? Colors.grey : Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${DateFormat('yyyy-MM-dd').format(start)} | ${DateFormat('hh:mm A').format(start)} - ${DateFormat('hh:mm A').format(end)}",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
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
