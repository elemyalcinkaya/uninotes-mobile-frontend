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
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } catch (e) {
        throw Exception('Yanıt işlenemedi: ${e.toString()}');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Notlar alınamadı');
      } catch (e) {
        throw Exception('Notlar alınamadı (HTTP ${response.statusCode})');
      }
    }
  }

  // Get shared notes (public notes shared by all users)
  Future<List<Map<String, dynamic>>> getSharedNotes() async {
    final url = Uri.parse('$baseUrl/notes/shared');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } catch (e) {
        throw Exception('Yanıt işlenemedi: ${e.toString()}');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Paylaşılan notlar yüklenemedi');
      } catch (e) {
        throw Exception('Paylaşılan notlar yüklenemedi (HTTP ${response.statusCode})');
      }
    }
  }

  // Get current user's notes only
  Future<List<Map<String, dynamic>>> getMyNotes() async {
    final url = Uri.parse('$baseUrl/notes/my');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } catch (e) {
        throw Exception('Yanıt işlenemedi: ${e.toString()}');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Notlarınız yüklenemedi');
      } catch (e) {
        throw Exception('Notlarınız yüklenemedi (HTTP ${response.statusCode})');
      }
    }
  }

  Future<Map<String, dynamic>> getNote(int id) async {
    final url = Uri.parse('$baseUrl/notes/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Yanıt işlenemedi: ${e.toString()}');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Not bulunamadı');
      } catch (e) {
        throw Exception('Not bulunamadı (HTTP ${response.statusCode})');
      }
    }
  }

  Future<Map<String, dynamic>> createNote({
    required String title,
    required String courseCode,
    required String summary,
    required int classLevel,
    required int semester,
  }) async {
    final url = Uri.parse('$baseUrl/notes');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'courseCode': courseCode,
        'summary': summary,
        'classLevel': classLevel,
        'semester': semester,
        'isShared': true,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Could not create note');
    }
  }

  Future<void> deleteNote(int noteId) async {
    final url = Uri.parse('$baseUrl/notes/$noteId');
    final response = await http.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Could not delete note');
      } catch (e) {
        throw Exception('Could not delete note (HTTP ${response.statusCode})');
      }
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
      // Check if response has content
      if (response.bodyBytes.isEmpty) {
        throw Exception('Dosya içeriği boş');
      }
      return response.bodyBytes;
    } else {
      // Try to parse error message, but handle JSON parsing errors
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Dosya indirilemedi');
      } catch (e) {
        // If JSON parsing fails, throw a generic error with status code
        throw Exception('Dosya indirilemedi (HTTP ${response.statusCode})');
      }
    }
  }

  // ---------------------------------------------------
  // 📌 CONTACT US
  // ---------------------------------------------------
  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/contact/send');
    final response = await http.post(
      url,
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Message could not be sent');
    }
  }

  // ---------------------------------------------------
  // 📌 DOSYA BİLGİSİ ALMA (Document Type için)
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getFiles({int? noteId}) async {
    final url = noteId != null
        ? Uri.parse('$baseUrl/files?noteId=$noteId')
        : Uri.parse('$baseUrl/files');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
        return [];
      } catch (e) {
        throw Exception('Dosya bilgisi alınamadı: ${e.toString()}');
      }
    } else {
      throw Exception('Dosya bilgisi alınamadı: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------
  // 📌 DERSLER (Sınıf ve Döneme Göre)
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getCoursesByClassAndSemester(
      int classLevel, int semester) async {
    final url = Uri.parse(
        '$baseUrl/courses/ByClassLevelAndSemester/$classLevel/$semester');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
        return [];
      } catch (e) {
        throw Exception('Dersler alınamadı: ${e.toString()}');
      }
    } else {
      throw Exception('Dersler alınamadı: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------
  // 📌 BİLDİRİM SEBEPLERİ
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getReportReasons() async {
    final url = Uri.parse('$baseUrl/reportreasons');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
        return [];
      } catch (e) {
        throw Exception('Bildirim sebepleri alınamadı: ${e.toString()}');
      }
    } else {
      throw Exception('Bildirim sebepleri alınamadı: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------
  // 📌 BİLDİRİM GÖNDER
  // ---------------------------------------------------
  Future<void> submitReport(int noteId, int reportReasonId) async {
    final url = Uri.parse('$baseUrl/reports');

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'noteId': noteId,
        'reportReasonId': reportReasonId,
      }),
    );

    if (response.statusCode != 200) {
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Bildirim gönderilemedi');
        } else {
          throw Exception('Bildirim gönderilemedi: ${response.statusCode}');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Bildirim gönderilemedi');
      }
    }
  }
}
