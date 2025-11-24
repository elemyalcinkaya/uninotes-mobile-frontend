import 'package:flutter/material.dart';
import 'package:uninotes_mobile/screens/home_page.dart';
import 'package:uninotes_mobile/screens/about_page.dart';
import 'package:uninotes_mobile/screens/shared_notes_page.dart';
import 'package:uninotes_mobile/screens/add_notes_page.dart';
import 'package:uninotes_mobile/screens/profile_page.dart';
import 'package:uninotes_mobile/screens/register_page.dart';
import 'package:uninotes_mobile/screens/login_page.dart';
import 'package:uninotes_mobile/theme.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TR locale date formatting
  await initializeDateFormatting('tr_TR', null);
  Intl.defaultLocale = 'tr_TR';

  runApp(const UniNotesApp()); // ← ARTIK BU ÇALIŞACAK
}

class UniNotesApp extends StatelessWidget {
  const UniNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniNotes',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(), // ← Senin tema fonksiyonun
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/about': (_) => const AboutPage(),
        '/shared-notes': (_) => const SharedNotesPage(),
        '/add-notes': (_) => const AddNotesPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
