import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  Future<File?> saveImage(Uint8List imageBytes, {required String fileName}) async {
    try {
      Directory.systemTemp.path;
      final file = await File('${Directory.systemTemp.path}/$fileName.png').create();
      await file.writeAsBytes(imageBytes);
      await Gal.putImage(file.path);
      return file;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  Future<String?> saveCsv(String csvContent, {required String fileName}) async {
    try {
      final String? file = await FilePicker.platform.saveFile(
        dialogTitle: 'Select folder to save $fileName',
        initialDirectory: await getDownloadsDirectory().then((dir) => dir?.path),
        fileName: '$fileName.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: utf8.encode(csvContent),
      );

      if (file == null) {
        return null;
      }

      return file;
    } catch (e) {
      debugPrint('Error saving CSV: $e');
      return null;
    }
  }
}
