import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  File? profileImage;
  User? currentUser;
  List<Map<String, dynamic>> uploadedNotes = [];
  bool isLoading = true;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      // Kullanıcı bilgilerini yükle
      final user = await _apiService.getUser();
      if (user != null) {
        setState(() {
          currentUser = user;
          usernameController.text = user.name;
          emailController.text = user.email;
        });
      }

      // Notları yükle
      final notes = await _apiService.getNotes();
      setState(() {
        uploadedNotes = notes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> saveProfile() async {
    // Backend'de profil güncelleme endpoint'i yok, sadece UI'da gösteriyoruz
    setState(() => isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncelleme özelliği yakında eklenecek')),
      );
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final joinDate = currentUser != null 
        ? DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now())
        : 'Bilinmiyor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // left card
              Expanded(
                flex: 1,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                              child: profileImage == null ? const Icon(Icons.person, size: 48) : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: pickProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6D28D9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo_camera, color: Colors.white, size: 18),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentUser?.name ?? 'Kullanıcı',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser?.email ?? '',
                          style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              '${uploadedNotes.length}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                            ),
                            const Text('Paylaşılan Not', style: TextStyle(color: Color(0xFF6B7280))),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Text('Katılım: $joinDate', style: const TextStyle(color: Color(0xFF6B7280))),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // right column
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Hesap Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                if (!isEditing)
                                  TextButton.icon(
                                    onPressed: () => setState(() => isEditing = true),
                                    icon: const Icon(Icons.edit, color: Color(0xFF7C3AED)),
                                    label: const Text('Düzenle', style: TextStyle(color: Color(0xFF7C3AED))),
                                  )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: [
                                if (isEditing)
                                  TextField(
                                    controller: usernameController,
                                    decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
                                  )
                                else
                                  _InfoRow(icon: Icons.person_outline, text: currentUser?.name ?? ''),
                                const SizedBox(height: 12),
                                if (isEditing)
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(labelText: 'E-posta Adresi'),
                                  )
                                else
                                  _InfoRow(icon: Icons.mail_outline, text: currentUser?.email ?? ''),
                                if (isEditing)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: saveProfile,
                                            child: const Text('Kaydet'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => setState(() => isEditing = false),
                                            child: const Text('İptal'),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Paylaşılan Notlarım', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const Icon(Icons.upload_file, color: Color(0xFF7C3AED)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${uploadedNotes.length} Not',
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7C3AED)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (uploadedNotes.isNotEmpty)
                              ...uploadedNotes.map((note) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFF3F4F6)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEDE9FE),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.description, color: Color(0xFF7C3AED)),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      note['title'] ?? 'Başlıksız',
                                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      note['courseCode'] ?? '',
                                                      style: const TextStyle(color: Color(0xFF7C3AED)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatDate(note['createdAt'] ?? DateTime.now().toIso8601String()),
                                          style: const TextStyle(color: Color(0xFF6B7280)),
                                        )
                                      ],
                                    ),
                                  ))
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(child: Text('Henüz not paylaşmadınız', style: TextStyle(color: Color(0xFF6B7280)))),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
