import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniNotes'),
        actions: [
          if (authProvider.isAuthenticated && authProvider.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  'Welcome, ${authProvider.user!.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
          ),
          if (authProvider.isAuthenticated) ...[
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/shared-notes'),
              icon: const Icon(Icons.sticky_note_2_outlined),
              tooltip: 'Shared Notes',
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/add-notes'),
              icon: const Icon(Icons.upload_file),
              tooltip: 'Add Note',
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.person_outline),
              tooltip: 'Profile',
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/contact'),
              icon: const Icon(Icons.contact_mail_outlined),
              tooltip: 'Contact Us',
            ),
            IconButton(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
          if (!authProvider.isAuthenticated) ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Register'),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Animated Background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7C3AED), // purple-600
                    const Color(0xFF6D28D9), // purple-700
                    const Color(0xFF4C1D95), // indigo-800
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Floating shapes
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withOpacity(0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4C1D95).withOpacity(0.2),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: Column(
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Your Knowledge Sharing Platform',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Main Heading
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFDE047), // yellow-300
                              Color(0xFFF9A8D4), // pink-300
                              Color(0xFFDDD6FE), // purple-200
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'UniNotes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        Text(
                          'Share knowledge, collaborate with peers, and excel together',
                          style: TextStyle(
                            color: const Color(0xFFDDD6FE).withOpacity(0.9),
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cards Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF9FAFB), // gray-50
                    const Color(0xFFF3E8FF).withOpacity(0.3), // purple-50
                    const Color(0xFFF9FAFB),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore our features and start sharing knowledge today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Feature Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          // Desktop layout - 3 columns
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Flexible(child: _FeatureCard(
                                icon: Icons.menu_book_rounded,
                                title: 'About',
                                desc: 'Learn more about UniNotes and how we help students share knowledge',
                                route: '/about',
                              )),
                              SizedBox(width: 16),
                              Flexible(child: _FeatureCard(
                                icon: Icons.sticky_note_2_outlined,
                                title: 'Shared Notes',
                                desc: 'Browse and download notes shared by fellow students',
                                route: '/shared-notes',
                              )),
                              SizedBox(width: 16),
                              Flexible(child: _FeatureCard(
                                icon: Icons.upload_file,
                                title: 'Add Your Note!',
                                desc: 'Share your notes with the community and help others succeed',
                                route: '/add-notes',
                              )),
                            ],
                          );
                        } else {
                          // Mobile layout - single column
                          return Column(
                            children: const [
                              _FeatureCard(
                                icon: Icons.menu_book_rounded,
                                title: 'About',
                                desc: 'Learn more about UniNotes and how we help students share knowledge',
                                route: '/about',
                              ),
                              SizedBox(height: 16),
                              _FeatureCard(
                                icon: Icons.sticky_note_2_outlined,
                                title: 'Shared Notes',
                                desc: 'Browse and download notes shared by fellow students',
                                route: '/shared-notes',
                              ),
                              SizedBox(height: 16),
                              _FeatureCard(
                                icon: Icons.upload_file,
                                title: 'Add Your Note!',
                                desc: 'Share your notes with the community and help others succeed',
                                route: '/add-notes',
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String route;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.route,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(maxWidth: 380),
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF7C3AED).withOpacity(0.3)
                  : const Color(0xFFDDD6FE).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF7C3AED).withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient top border
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7C3AED), // purple-500
                        Color(0xFFEC4899), // pink-500
                        Color(0xFF4F46E5), // indigo-500
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 96,
                      width: 96,
                      transform: Matrix4.rotationZ(_isHovered ? 0.1 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFDDD6FE), // purple-100
                            const Color(0xFFE9D5FF), // purple-200
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF6D28D9),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isHovered 
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF111827),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      widget.desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
