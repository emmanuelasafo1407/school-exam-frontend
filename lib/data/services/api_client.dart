import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiClient {
  final String baseUrl = "http://172.20.10.3:8000/api";
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://172.20.10.3:8000/api'));

  // --- ADMIN DASHBOARD & TIMETABLE (Using Dio) ---
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _dio.get('/admin/stats');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception("Failed to fetch admin stats: $e");
    }
  }

  Future<Map<String, dynamic>> uploadStudentCsv(String filePath) async {
    FormData formData = FormData.fromMap({
      "csv_file": await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/admin/import-students', data: formData);
    return response.data;
  }

  Future<List<dynamic>> fetchStudents() async {
    final response = await _dio.get('/admin/users?role=student');
    return response.data['data'];
  }

  Future<void> updateStudentStatus(int userId, bool isQualified) async {
    await _dio.patch(
      '/admin/users/$userId/status',
      data: {'is_qualified': isQualified},
    );
  }

  Future<List<dynamic>> fetchExamSessions() async {
    final response = await _dio.get('/admin/sessions');
    return response.data;
  }

  Future<void> createExamSession(Map<String, dynamic> data) async {
    await _dio.post('/admin/sessions', data: data);
  }

  Future<void> toggleSessionStatus(int id, bool isActive) async {
    await _dio.patch(
      '/admin/sessions/$id/toggle',
      data: {'is_active': isActive},
    );
  }

  // --- AUTH & STUDENT OPERATIONS (Original Custom Logic) ---
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
        Uri.parse("$baseUrl/register/invigilator"),
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
          "Accept": "application/json",
        },
        body: jsonEncode({
          "student_id_number": studentId,
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
  // --- INVIGILATOR VERIFICATION ---

  Future<List<dynamic>> fetchPendingInvigilators() async {
    final response = await _dio.get('/admin/invigilators/pending');
    return response.data;
  }

  Future<void> verifyInvigilator(int id) async {
    await _dio.patch('/admin/invigilators/$id/verify');
  }
  // Add these to ApiClient class in lib/data/services/api_client.dart

  // --- ATTENDANCE ---

  Future<void> logAttendance(Map<String, dynamic> data) async {
    await _dio.post('/log-attendance', data: data);
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

  Future<List<dynamic>> fetchAllAttendanceLogs() async {
    final response = await _dio.get('/attendance/logs');
    return response.data;
  }

  Future<Map<String, dynamic>> logoutUser(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
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
          "Accept": "application/json",
        },
      );
      if (response.statusCode != 200) {
        return {
          "statusCode": response.statusCode,
          "body": {"message": "Server error: ${response.statusCode}"},
        };
      }
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"message": "Exception: $e"},
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
        "body": {"message": "Failed to log script: $e"},
      };
    }
  }
}
