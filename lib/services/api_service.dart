import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3001/api';

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Gửi OTP đăng ký
  static Future<Map<String, dynamic>> sendRegistrationOTP({
    required String email,
    required String username,
    String? fullName,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-registration-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'username': username, 'fullName': fullName ?? ''}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Xác thực OTP và hoàn tất đăng ký
  static Future<Map<String, dynamic>> verifyRegistrationOTP({
    required String email,
    required String otpCode,
    required String username,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-registration-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otpCode': otpCode,
        'username': username,
        'password': password,
        'fullName': fullName,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      }),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Đăng nhập
  static Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emailOrUsername': emailOrUsername, 'password': password}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Gửi OTP reset mật khẩu
  static Future<Map<String, dynamic>> sendPasswordResetOTP({
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-password-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Reset mật khẩu với OTP
  static Future<Map<String, dynamic>> resetPasswordWithOTP({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otpCode': otpCode, 'newPassword': newPassword}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Token Storage ─────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
