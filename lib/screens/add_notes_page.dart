import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  PlatformFile? pickedFile;
  final courseNameController = TextEditingController();
  final courseCodeController = TextEditingController();
  final descriptionController = TextEditingController();
  bool uploading = false;
  bool uploadSuccess = false;
  final _apiService = ApiService();
  
  String? selectedClass;
  String? selectedSemester;
  
  // Course selection state
  List<Map<String, dynamic>> availableCourses = [];
  String? selectedCourseCode;
  bool loadingCourses = false;
  
  final List<String> classes = ['1', '2', '3', '4'];
  final List<String> semesters = ['Fall', 'Spring'];

  @override
  void dispose() {
    courseNameController.dispose();
    courseCodeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    if (selectedClass == null || selectedSemester == null) {
      setState(() => availableCourses = []);
      return;
    }

    setState(() => loadingCourses = true);
    try {
      final courses = await _apiService.getCoursesByClassAndSemester(
        int.parse(selectedClass!),
        selectedSemester == 'Fall' ? 1 : 2,
      );
      setState(() {
        availableCourses = courses;
        loadingCourses = false;
      });
    } catch (e) {
      setState(() => loadingCourses = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load courses: $e')),
        );
      }
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => pickedFile = result.files.single);
    }
  }

  void removeFile() {
    setState(() {
      pickedFile = null;
      courseNameController.clear();
      courseCodeController.clear();
      descriptionController.clear();
      selectedClass = null;
      selectedSemester = null;
    });
  }

  Future<void> upload() async {
    if (pickedFile == null ||
        courseNameController.text.isEmpty ||
        courseCodeController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedClass == null ||
        selectedSemester == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields!')),
        );
      }
      return;
    }

    setState(() => uploading = true);

    try {
      // Create note with class and semester
      final note = await _apiService.createNote(
        title: courseNameController.text,
        courseCode: courseCodeController.text,
        summary: descriptionController.text,
        classLevel: int.parse(selectedClass!),
        semester: selectedSemester == 'Fall' ? 1 : 2,
      );

      // Upload file
      if (kIsWeb) {
        await _apiService.uploadFileWeb(
          bytes: pickedFile!.bytes!,
          filename: pickedFile!.name,
          noteId: note['id'],
          title: pickedFile!.name,
        );
      } else {
        final file = File(pickedFile!.path!);
        await _apiService.uploadFile(
          file: file,
          noteId: note['id'],
          title: pickedFile!.name,
        );
      }

      if (!mounted) return;

      setState(() {
        uploading = false;
        uploadSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Note uploaded successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          uploadSuccess = false;
          pickedFile = null;
          courseNameController.clear();
          courseCodeController.clear();
          descriptionController.clear();
          selectedClass = null;
          selectedSemester = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = pickedFile != null &&
        courseNameController.text.isNotEmpty &&
        courseCodeController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedClass != null &&
        selectedSemester != null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Text(
              'Add Note',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your notes with fellow students',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // File Upload Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upload File',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    if (pickedFile == null)
                      InkWell(
                        onTap: pickFile,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFD1D5DB),
                                width: 2,
                                style: BorderStyle.solid),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 40, color: Color(0xFF9CA3AF)),
                                SizedBox(height: 8),
                                Text('Select file',
                                    style: TextStyle(color: Color(0xFF374151))),
                                SizedBox(height: 4),
                                Text('PDF, DOCX, JPEG, JPG (Max. 50MB)',
                                    style: TextStyle(
                                        color: Color(0xFF9CA3AF), fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description,
                                color: Color(0xFF7C3AED)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pickedFile!.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    '${((pickedFile!.size) / 1024 / 1024).toStringAsFixed(2)} MB',
                                    style: const TextStyle(
                                        color: Color(0xFF6B7280), fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: removeFile,
                            icon: const Icon(Icons.close,
                                color: Color(0xFF9CA3AF)),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (pickedFile != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: courseNameController,
                        decoration: const InputDecoration(
                          labelText: 'Course Name',
                          hintText: 'e.g., Introduction to Programming',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      
                      // Class Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          hintText: 'Select class',
                        ),
                        items: classes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Class $value'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedClass = newValue;
                            selectedCourseCode = null;
                            courseCodeController.clear();
                            _loadCourses();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Semester Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedSemester,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          hintText: 'Select semester',
                        ),
                        items: semesters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSemester = newValue;
                            selectedCourseCode = null;
                            courseCodeController.clear();
                            _loadCourses();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Course Code Dropdown (Dynamic)
                      if (selectedClass != null && selectedSemester != null)
                        loadingCourses
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                value: selectedCourseCode,
                                decoration: const InputDecoration(
                                  labelText: 'Course Code',
                                  hintText: 'Select course',
                                ),
                                items: availableCourses.map((course) {
                                  final courseCode = course['courseCode'] ?? '';
                                  final courseName = course['courseName'];
                                  final displayText = courseName != null && courseName.toString().isNotEmpty
                                      ? '$courseCode - $courseName'
                                      : courseCode;
                                  
                                  return DropdownMenuItem<String>(
                                    value: course['courseCode'],
                                    child: Text(displayText),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedCourseCode = value;
                                    courseCodeController.text = value ?? '';
                                  });
                                },
                              )
                      else
                        TextField(
                          controller: courseCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Course Code',
                            hintText: 'Select class and semester first',
                          ),
                          enabled: false,
                        ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Note Description',
                          hintText: 'What topics does this note cover?',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${descriptionController.text.length}/500 characters',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: (!isFormValid || uploading || uploadSuccess)
                  ? null
                  : upload,
              icon: uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(uploadSuccess ? Icons.check : Icons.upload_file),
              label: Text(uploading
                  ? 'Uploading...'
                  : uploadSuccess
                      ? 'Successfully Uploaded!'
                      : 'Upload Note'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
            ),

            if (!isFormValid && pickedFile != null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text('Please fill all fields',
                      style: TextStyle(color: Color(0xFF92400E))),
                ),
              ),

            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFF5F3FF),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📚 Note Sharing Rules',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('• Only upload notes you created or have permission to share'),
                    Text('• Ensure your notes are readable and well-organized'),
                    Text('• Do not share inappropriate content'),
                    Text('• Only PDF, DOCX, JPEG or JPG formats allowed'),
                    Text('• File size must not exceed 50MB'),
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
