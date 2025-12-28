import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uninotes_mobile/providers/auth_provider.dart';
import 'package:uninotes_mobile/screens/landing_page.dart';
import 'package:uninotes_mobile/screens/main_scaffold.dart';
import 'package:uninotes_mobile/screens/register_page.dart';
import 'package:uninotes_mobile/screens/login_page.dart';
import 'package:uninotes_mobile/theme.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EN locale date formatting
  await initializeDateFormatting('en_US', null);
  Intl.defaultLocale = 'en_US';

  runApp(const UniNotesApp());
}

class UniNotesApp extends StatelessWidget {
  const UniNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'UniNotes - Share & Learn Together',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const LandingPage(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const MainScaffold(),
        },
      ),
    );
  }
}
