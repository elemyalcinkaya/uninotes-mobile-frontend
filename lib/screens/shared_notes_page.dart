import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/file_downloader.dart';

class SharedNotesPage extends StatefulWidget {
  const SharedNotesPage({super.key});

  @override
  State<SharedNotesPage> createState() => _SharedNotesPageState();
}

class _SharedNotesPageState extends State<SharedNotesPage> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> filteredNotes = [];
  bool isLoading = true;
  String selectedClass = 'All Classes';
  String selectedSemester = 'All Semesters';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    try {
      final loadedNotes = await _apiService.getSharedNotes();
      setState(() {
        notes = loadedNotes;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    filteredNotes = notes.where((note) {
      if (selectedClass != 'All Classes') {
        final noteClass = note['classLevel']?.toString() ?? note['grade']?.toString() ?? '';
        if (noteClass != selectedClass) return false;
      }
      if (selectedSemester != 'All Semesters') {
        final noteSemester = note['semester']?.toString() ?? '';
        final semesterMap = {'1': 'Fall', '2': 'Spring'};
        final displaySemester = semesterMap[noteSemester] ?? noteSemester;
        if (displaySemester != selectedSemester) return false;
      }
      return true;
    }).toList();
  }

  List<String> _getUniqueClasses() {
    final classes = <String>{};
    for (var note in notes) {
      final grade = note['classLevel']?.toString() ?? note['grade']?.toString() ?? '';
      if (grade.isNotEmpty) classes.add(grade);
    }
    return ['All Classes', ...classes.toList()..sort()];
  }

  List<String> _getUniqueSemesters() {
    return ['All Semesters', 'Fall', 'Spring'];
  }

  Future<void> _downloadNote(int noteId) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading...')),
        );
      }

      final note = await _apiService.getNote(noteId);
      final files = note['files'] as List<dynamic>?;

      if (files == null || files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file found'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      final fileName = files[0]['fileName'] ?? files[0]['originalName'] ?? 'note.pdf';
      final fileId = files[0]['id'];
      final bytes = await _apiService.downloadFile(fileId);
      
      await FileDownloader.downloadFile(bytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Shared Notes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadNotes,
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (notes.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 64, color: Color(0xFF7C3AED)),
                      const SizedBox(height: 16),
                      const Text('No notes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Be the first to share!', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Filters
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedClass,
                              decoration: const InputDecoration(
                                labelText: 'Class',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _getUniqueClasses().map((c) {
                                return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedClass = value!;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedSemester,
                              decoration: const InputDecoration(
                                labelText: 'Semester',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _getUniqueSemesters().map((s) {
                                return DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSemester = value!;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notes Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          final user = note['user'] as Map<String, dynamic>?;
                          final userName = user?['name'] ?? 'Unknown';
                          
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 400 + (index * 100)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      onTap: () => _downloadNote(note['id']),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDE9FE),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.description, color: Color(0xFF7C3AED), size: 28),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              note['title'] ?? 'Untitled',
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              note['courseCode'] ?? '',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                const Icon(Icons.person, size: 12, color: Color(0xFF7C3AED)),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    userName,
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(note['createdAt'] ?? ''),
                                              style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Download Button
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                                      ),
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                        onTap: () => _downloadNote(note['id']),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.download, color: Colors.white, size: 18),
                                              SizedBox(width: 6),
                                              Text(
                                                'Download',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
