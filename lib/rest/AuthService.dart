import 'dart:convert';

import 'package:http/http.dart';

class AuthService {
  static String BASE_URL = 'http://192.168.178.21:8000/api';

  static Future<Response> login(String email, String password) {
    return post(
      Uri.parse('$BASE_URL/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<Response> logout(String token) {
    return post(
      Uri.parse('$BASE_URL/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
