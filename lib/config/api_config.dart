// API Configuration
class ApiConfig {
  // Base URL - platform-specific
  static String get baseUrl {
    // This will be overridden by ApiService based on platform
    return 'http://localhost:5276/api';
  }

  // API Endpoints
  static const auth = AuthEndpoints();
  static const notes = NotesEndpoints();
  static const files = FilesEndpoints();
  static const contact = ContactEndpoints();
}

// Auth Endpoints
class AuthEndpoints {
  const AuthEndpoints();
  
  String get register => '/auth/register';
  String get login => '/auth/login';
}

// Notes Endpoints
class NotesEndpoints {
  const NotesEndpoints();
  
  String get list => '/notes';
  String get shared => '/notes/shared';
  String get my => '/notes/my';
  String get create => '/notes';
  
  String getById(int id) => '/notes/$id';
  String update(int id) => '/notes/$id';
  String delete(int id) => '/notes/$id';
}

// Files Endpoints
class FilesEndpoints {
  const FilesEndpoints();
  
  String get list => '/files';
  String get upload => '/files/upload';
  
  String download(int id) => '/files/download/$id';
  String delete(int id) => '/files/$id';
}

// Contact Endpoints
class ContactEndpoints {
  const ContactEndpoints();
  
  String get send => '/contact/send';
}

// Helper function to get full URL
String getApiUrl(String endpoint, String baseUrl) {
  return '$baseUrl$endpoint';
}
