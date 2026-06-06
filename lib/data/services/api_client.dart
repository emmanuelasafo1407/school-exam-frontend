import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ⚠️ REPLACE THIS IP WITH YOUR CURRENT PC IP FROM IPCONFIG
  final String baseUrl = "http://172.20.10.3:8000/api";

  Future<Map<String, dynamic>> registerStudent(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register/student"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }

  // 👈 NEW: Secure Network Endpoint for Student & Invigilator Logins
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> registerInvigilator(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/register/invigilator",
        ), // We will map this route next
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchStudentProfile(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/student/verify/$studentId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> logStudentAttendance({
    required String studentId,
    required String courseCode,
    required String courseName,
    required String lecturerName,
    required String hall,
    required String startTime,
    required String endTime,
    required int invigilatorId,
    required String paperCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/log-attendance"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // 👈 ENFORCES JSON output on failure
        },
        body: jsonEncode({
          "student_id_number":
              studentId, // 👈 FIXED: Matches Laravel validation rule key
          "course_code": courseCode,
          "course_name": courseName,
          "lecturer_name": lecturerName,
          "hall": hall,
          "start_time": startTime,
          "end_time": endTime,
          "invigilator_id": invigilatorId,
          "paper_code": paperCode,
        }),
      );

      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": "Network tracking failure trace: $e"},
      };
    }
  }

  Future<Map<String, dynamic>> fetchSessionAnalytics(String courseCode) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/attendance/analytics/$courseCode"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchDetailedLedger(String courseCode) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/attendance/ledger/$courseCode"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> logoutUser(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // Passes secure bearer verification header string
        },
      );

      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": "Network connection dropped context: $e"},
      };
    }
  }

  Future<Map<String, dynamic>> fetchVerifiedStudentProfile(
    String studentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/student-profile/$studentId"),
        headers: {
          "Content-Type": "application/json",
          "Accept":
              "application/json", // 👈 Tells Laravel to ALWAYS return JSON instead of HTML web pages
        },
      );

      // Gracefully handle server crashes or bad route targets without crashing the JSON parser
      if (response.statusCode != 200) {
        return {
          "statusCode": response.statusCode,
          "body": {
            "message": "Server returned error code: ${response.statusCode}",
          },
        };
      }

      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": "Exception occurred during fetch operation: $e"},
      };
    }
  }

  Future<Map<String, dynamic>> submitExamPaper({
    required String studentId,
    required String courseCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/submit-paper"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "student_id_number": studentId,
          "course_code": courseCode,
        }),
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": "Failed to log script submission: $e"},
      };
    }
  }
}
