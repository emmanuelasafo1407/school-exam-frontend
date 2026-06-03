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

  Future<Map<String, dynamic>> logAttendance(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance/log"),
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
}
