import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  static Future<void> downloadFile(List<int> bytes, String fileName) async {
    if (kIsWeb) {
      // Web implementation
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile implementation
      try {
        // Get the downloads directory
        Directory? directory;
        
        if (Platform.isAndroid) {
          // For Android, use the Downloads directory
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else if (Platform.isIOS) {
          // For iOS, use the documents directory
          directory = await getApplicationDocumentsDirectory();
        } else {
          // For other platforms (Windows, macOS, Linux)
          directory = await getDownloadsDirectory();
        }

        if (directory == null) {
          throw Exception('Download dizini bulunamadı');
        }

        // Create the file path
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Write the bytes to the file
        await file.writeAsBytes(bytes);

        debugPrint('Dosya indirildi: $filePath');
      } catch (e) {
        debugPrint('Mobil indirme hatası: $e');
        rethrow;
      }
    }
  }
}
