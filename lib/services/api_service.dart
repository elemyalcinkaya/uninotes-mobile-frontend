import 'dart:convert';
import 'dart:io' show Platform, File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5276/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5276/api';
    } else {
      return 'http://localhost:5276/api';
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userKey,
      jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
      }),
    );
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
      );
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final user = _handleAuthResponse(response);
    if (user.token != null) {
      await saveToken(user.token!);
      await saveUser(user);
    }
    return user;
  }

  Future<User> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final user = _handleAuthResponse(response);
    if (user.token != null) {
      await saveToken(user.token!);
      await saveUser(user);
    }
    return user;
  }

  User _handleAuthResponse(http.Response response) {
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'İşlem başarısız oldu');
    }
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final url = Uri.parse('$baseUrl/notes');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Notlar alınamadı');
    }
  }

  Future<Map<String, dynamic>> getNote(int id) async {
    final url = Uri.parse('$baseUrl/notes/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Not bulunamadı');
    }
  }

  Future<Map<String, dynamic>> createNote({
    required String title,
    required String courseCode,
    required String summary,
  }) async {
    final url = Uri.parse('$baseUrl/notes');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'courseCode': courseCode,
        'summary': summary,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Not oluşturulamadı');
    }
  }

  // ---------------------------------------------------
  // 📌 MOBİL / EMÜLATÖR DOSYA YÜKLEME
  // ---------------------------------------------------
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    int? noteId,
    String? title,
  }) async {
    final url = Uri.parse('$baseUrl/files/upload');

    final token = await getToken();
    if (token == null) {
      throw Exception('Oturum açmanız gerekiyor');
    }

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    if (noteId != null) request.fields['noteId'] = noteId.toString();
    if (title != null) request.fields['title'] = title;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Dosya yüklenemedi: ${response.body}');
    }
  }

  // ---------------------------------------------------
  // 📌 WEB DOSYA YÜKLEME
  // ---------------------------------------------------
  Future<Map<String, dynamic>> uploadFileWeb({
    required Uint8List bytes,
    required String filename,
    int? noteId,
    String? title,
  }) async {
    final url = Uri.parse('$baseUrl/files/upload');
    final token = await getToken();
    if (token == null) throw Exception('Oturum açmanız gerekiyor');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    if (noteId != null) request.fields['noteId'] = noteId.toString();
    if (title != null) request.fields['title'] = title;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('WEB yükleme hatası: ${response.body}');
    }
  }

  // ---------------------------------------------------
  // 📌 DOSYA İNDİRME
  // ---------------------------------------------------
  Future<List<int>> downloadFile(int id) async {
    final url = Uri.parse('$baseUrl/files/download/$id');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Dosya indirilemedi');
    }
  }
}
