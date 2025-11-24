import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _apiService.getToken();
    if (token == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniNotes'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset(
            'assets/images/last-logo.png',
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                'Welcome to ',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
                ).createShader(Offset.zero & const Size(200, 50)),
                child: Text(
                  'UniNotes',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                children: const [
                  _NavCard(
                    icon: Icons.menu_book_rounded,
                    title: 'About',
                    desc:
                        'Learn more about UniNotes and how we help students share knowledge',
                    route: '/about',
                  ),
                  _NavCard(
                    icon: Icons.sticky_note_2_outlined,
                    title: 'Shared Notes',
                    desc: 'Browse and download notes shared by fellow students',
                    route: '/shared-notes',
                  ),
                  _NavCard(
                    icon: Icons.upload_file,
                    title: 'Add Your Note!',
                    desc:
                        'Share your notes with the community and help others succeed',
                    route: '/add-notes',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String route;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFE9D5FF), // purple-200
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF6D28D9), size: 44),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.info_outline), label: 'About'),
        NavigationDestination(icon: Icon(Icons.sticky_note_2_outlined), label: 'Notes'),
        NavigationDestination(icon: Icon(Icons.upload_file), label: 'Add'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/about');
            break;
          case 1:
            Navigator.pushNamed(context, '/shared-notes');
            break;
          case 2:
            Navigator.pushNamed(context, '/add-notes');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      selectedIndex: 0,
    );
  }
}




