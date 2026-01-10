import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/file_downloader.dart';
import '../widgets/report_dialog.dart';

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
      
      // Fetch detailed info for each note to get files
      final notesWithFiles = <Map<String, dynamic>>[];
      for (var note in loadedNotes) {
        try {
          final detailedNote = await _apiService.getNote(note['id']);
          notesWithFiles.add(detailedNote);
        } catch (e) {
          // If we can't get details, use the basic note
          notesWithFiles.add(note);
        }
      }
      
      setState(() {
        notes = notesWithFiles;
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

  Widget _getDocumentIcon(Map<String, dynamic> note) {
    // Check if note has files array with file info
    final files = note['files'] as List<dynamic>?;
    if (files != null && files.isNotEmpty) {
      final fileName = (files[0]['fileName'] ?? files[0]['originalName'] ?? '').toString();
      if (fileName.isNotEmpty) {
        final extension = fileName.split('.').last.toLowerCase();
        
        switch (extension) {
          case 'pdf':
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          case 'doc':
          case 'docx':
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'DOCX',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          case 'jpg':
          case 'jpeg':
          case 'png':
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'IMG',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
        }
      }
    }
    return const SizedBox.shrink(); // Don't show anything if no file
  }

  Color _getUserColor(String userName) {
    // Generate a consistent color based on username
    final colors = [
      const Color(0xFFFF85C0), // Darker Pink (was FFB3D9)
      const Color(0xFFFFB380), // Light Orange
      const Color(0xFF80B3FF), // Light Blue
    ];
    
    // Use hashCode to get consistent color for same username
    final index = userName.hashCode.abs() % colors.length;
    return colors[index];
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
                            child: Stack(
                              children: [
                                Card(
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
                                                    Icon(Icons.person, size: 12, color: _getUserColor(userName)),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        userName,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: _getUserColor(userName),
                                                          fontWeight: FontWeight.w600,
                                                        ),
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
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Document Type Icon
                                                  _getDocumentIcon(note),
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.download, color: Colors.white, size: 18),
                                                  const SizedBox(width: 6),
                                                  const Text(
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
                                // Report Button - Top Right
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.amber.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ReportDialog(noteId: note['id']),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              'Report',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
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
