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

  @override
  void dispose() {
    courseNameController.dispose();
    courseCodeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => pickedFile = result.files.single);
    }
  }

  void removeFile() {
    setState(() => pickedFile = null);
    courseNameController.clear();
    courseCodeController.clear();
    descriptionController.clear();
  }

  Future<void> upload() async {
  if (pickedFile == null ||
      courseNameController.text.isEmpty ||
      courseCodeController.text.isEmpty ||
      descriptionController.text.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
      );
    }
    return;
  }

  setState(() => uploading = true);

  try {
    // 1) Önce notu oluştur
    final note = await _apiService.createNote(
      title: courseNameController.text,
      courseCode: courseCodeController.text,
      summary: descriptionController.text,
    );

    // 2) Dosya yükleme - WEB ve MOBİL ayrımı
    if (kIsWeb) {
      // WEB kullandığımız için bytes yolu
      await _apiService.uploadFileWeb(
        bytes: pickedFile!.bytes!,
        filename: pickedFile!.name,
        noteId: note['id'],
        title: pickedFile!.name,
      );
    } else {
      // MOBİL / EMÜLATÖR path yolu
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
      const SnackBar(content: Text('Not başarıyla yüklendi!')),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        uploadSuccess = false;
        pickedFile = null;
        courseNameController.clear();
        courseCodeController.clear();
        descriptionController.clear();
      });
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Yükleme hatası: ${e.toString().replaceAll('Exception: ', '')}'),
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
        descriptionController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Not Ekle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dosya Yükle',
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
                          border: Border.all(color: const Color(0xFFD1D5DB), width: 2, style: BorderStyle.solid),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF9CA3AF)),
                              SizedBox(height: 8),
                              Text('Dosyayı seç', style: TextStyle(color: Color(0xFF374151))),
                              SizedBox(height: 4),
                              Text('PDF, DOC, DOCX, PPT, PPTX (Maks. 50MB)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
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
                          child: const Icon(Icons.description, color: Color(0xFF7C3AED)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pickedFile!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${((pickedFile!.size) / 1024 / 1024).toStringAsFixed(2)} MB',
                                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: removeFile,
                          icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
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
                        labelText: 'Ders Adı',
                        hintText: 'Örn: Introduction to Programming',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: courseCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Ders Kodu',
                        hintText: 'Örn: CS 101',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Not Açıklaması',
                        hintText: 'Bu notlar hangi konuları içeriyor?',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${descriptionController.text.length}/500 karakter',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: (!isFormValid || uploading || uploadSuccess) ? null : upload,
            icon: uploading
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(uploadSuccess ? Icons.check : Icons.upload_file),
            label: Text(uploading
                ? 'Yükleniyor...'
                : uploadSuccess
                    ? 'Başarıyla Yüklendi!'
                    : 'Notu Yükle'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          ),

          if (!isFormValid && pickedFile != null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text('Lütfen tüm alanları doldurun',
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
                  Text('📚 Not Paylaşım Kuralları', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('• Sadece kendi hazırladığınız veya paylaşım izni olan notları yükleyin'),
                  Text('• Notlarınızın okunaklı ve düzenli olduğundan emin olun'),
                  Text('• Uygun olmayan içerik paylaşmayın'),
                  Text('• Dosya boyutu 50MB\'ı geçmemelidir'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
