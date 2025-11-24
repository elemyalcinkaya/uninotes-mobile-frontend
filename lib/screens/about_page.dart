import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF5B21B6)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to ',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
                    ).createShader(bounds),
                    child: Text(
                      'UniNotes',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A modern, collaborative platform where students connect through knowledge sharing',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // What is UniNotes
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFEDE9FE),
                              child: Icon(Icons.menu_book_rounded, color: Color(0xFF6D28D9)),
                            ),
                            SizedBox(width: 12),
                            Text('What is UniNotes?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'UniNotes is a community-driven platform where university students can share their lecture notes, discover useful resources, and download materials to boost their learning.',
                          style: TextStyle(fontSize: 16, height: 1.4),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our mission is to enhance collaboration and efficient learning by connecting learners in a clean, fast, and reliable environment.',
                          style: TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Who we are
                Card(
                  color: const Color(0xFFF5F3FF),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFF7C3AED),
                              child: Icon(Icons.group, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Who We Are?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'The UniNotes team consists of students and educators from various departments. We develop with principles of transparency, accessibility, and academic integrity.',
                          style: TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Why UniNotes
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFF6D28D9),
                              child: Icon(Icons.auto_awesome, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Why UniNotes?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('We provide an exceptional learning experience with these key features:',
                              style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 8),
                        const _FeatureRow(icon: Icons.lightbulb, title: 'Modern Interface', desc: 'Easy navigation and quick access to notes'),
                        const _FeatureRow(icon: Icons.bolt, title: 'Smart Tagging', desc: 'Find exactly what you\'re looking for'),
                        const _FeatureRow(icon: Icons.groups_2, title: 'Quality Content', desc: 'Peer-reviewed content and community feedback'),
                        const _FeatureRow(icon: Icons.verified_user, title: 'Safe & Secure', desc: 'Your notes are safe and accessible anytime'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contact footer
                Card(
                  color: const Color(0xFF111827),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contact Us', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ContactChip(
                              label: 'info@uninotes.app',
                              icon: Icons.mail_outline,
                              onTap: () => launchUrl(Uri.parse('mailto:info@uninotes.app')),
                            ),
                            _ContactChip(
                              label: '+90 000 000 00 00',
                              icon: Icons.phone_outlined,
                              onTap: () => launchUrl(Uri.parse('tel:+900000000000')),
                            ),
                            _ContactChip(
                              label: 'uninotes.app',
                              icon: Icons.public,
                              onTap: () => launchUrl(Uri.parse('https://uninotes.app')),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ContactChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onPressed: onTap,
      backgroundColor: Colors.white10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}




