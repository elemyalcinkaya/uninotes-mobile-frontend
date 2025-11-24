import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class SharedNotesPage extends StatefulWidget {
  const SharedNotesPage({super.key});

  @override
  State<SharedNotesPage> createState() => _SharedNotesPageState();
}

class _SharedNotesPageState extends State<SharedNotesPage> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    try {
      final loadedNotes = await _apiService.getNotes();
      setState(() {
        notes = loadedNotes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notlar yüklenirken hata: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadNote(int noteId) async {
    try {
      // Not detayını al
      final note = await _apiService.getNote(noteId);
      final files = note['files'] as List<dynamic>?;

      if (files == null || files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu not için dosya bulunamadı')),
          );
        }
        return;
      }

      // İlk dosyayı indir
      final fileId = files[0]['id'];
      final bytes = await _apiService.downloadFile(fileId); // ✔ DÜZELTİLDİ

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya indirildi (${bytes.length} bytes)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İndirme hatası: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMd().format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşılan Notlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 64, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 12),
                      const Text('Henüz not bulunmuyor', style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/add-notes'),
                        icon: const Icon(Icons.add),
                        label: const Text('İlk Notunu Ekle'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (_, i) => _NoteCard(
                      note: notes[i],
                      onDownload: () => _downloadNote(notes[i]['id']),
                    ),
                  ),
                ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onDownload;

  const _NoteCard({required this.note, required this.onDownload});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMd().format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(note['createdAt'] ?? DateTime.now().toIso8601String());
    final fileCount = note['fileCount'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEDE9FE),
                  child: Icon(Icons.menu_book_rounded, color: Color(0xFF7C3AED)),
                ),
                if (fileCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$fileCount dosya',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF7C3AED)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note['title'] ?? 'Başlıksız',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              note['courseCode'] ?? '',
              style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note['summary'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('İndir', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
