import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'folder_structure_service.dart';

class FileService {
  static FileService? _instance;
  static FileService get instance => _instance ??= FileService._();
  
  FileService._();

  final FolderStructureService _folderService = FolderStructureService.instance;

  Future<List<Map<String, dynamic>>> readCsvFile(String filePath, {int? testRows}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final content = await file.readAsString();
      final csvData = const CsvToListConverter().convert(content);
      
      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      final headers = csvData[0].map((e) => e.toString().trim()).toList();
      final rows = csvData.skip(1).toList();
      
      final result = <Map<String, dynamic>>[];
      final maxRows = testRows != null && testRows > 0 ? testRows : rows.length;
      
      for (int i = 0; i < maxRows && i < rows.length; i++) {
        final row = rows[i];
        final rowMap = <String, dynamic>{};
        
        for (int j = 0; j < headers.length; j++) {
          final value = j < row.length ? row[j].toString().trim() : '';
          rowMap[headers[j]] = value;
        }
        
        result.add(rowMap);
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to read CSV file: $e');
    }
  }

  Future<List<Map<String, dynamic>>> readExcelFile(String filePath, {int? testRows}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      if (excel.tables.isEmpty) {
        throw Exception('Excel file has no sheets');
      }

      final sheet = excel.tables.values.first;
      if (sheet.rows.isEmpty) {
        throw Exception('Excel sheet is empty');
      }

      final headers = sheet.rows[0].map((e) => e?.toString().trim() ?? '').toList();
      final rows = sheet.rows.skip(1).toList();
      
      final result = <Map<String, dynamic>>[];
      final maxRows = testRows != null && testRows > 0 ? testRows : rows.length;
      
      for (int i = 0; i < maxRows && i < rows.length; i++) {
        final row = rows[i];
        final rowMap = <String, dynamic>{};
        
        for (int j = 0; j < headers.length; j++) {
          final value = j < row.length ? row[j]?.toString().trim() ?? '' : '';
          rowMap[headers[j]] = value;
        }
        
        result.add(rowMap);
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to read Excel file: $e');
    }
  }

  Future<List<Map<String, dynamic>>> readDataFile(String filePath, {int? testRows}) async {
    final extension = filePath.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'csv':
        return readCsvFile(filePath, testRows: testRows);
      case 'xlsx':
      case 'xlsm':
        return readExcelFile(filePath, testRows: testRows);
      default:
        // Try CSV as fallback
        return readCsvFile(filePath, testRows: testRows);
    }
  }

  Future<String?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['csv', 'xlsx', 'xlsm'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  Future<String> getOutputDirectory() async {
    return _folderService.outputDirectory.path;
  }

  Future<String> saveResults(List<dynamic> results, String pattern) async {
    try {
      // Use organized output path (organized by date)
      final filePath = _folderService.getOrganizedOutputFilePath(pattern);
      
      final file = File(filePath);
      await file.writeAsString(
        _formatJson(results),
        flush: true,
      );
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to save results: $e');
    }
  }

  /// Get all output files
  Future<List<File>> getOutputFiles() async {
    return await _folderService.getOutputFiles();
  }

  /// Get output files by date range
  Future<List<File>> getOutputFilesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final outputFiles = await getOutputFiles();
      return outputFiles.where((file) {
        final lastModified = file.lastModifiedSync();
        return lastModified.isAfter(startDate) && lastModified.isBefore(endDate);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _formatJson(List<dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('[');
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      buffer.write('  ${_formatJsonValue(item, 1)}');
      if (i < data.length - 1) {
        buffer.write(',');
      }
      buffer.writeln();
    }
    
    buffer.write(']');
    return buffer.toString();
  }

  String _formatJsonValue(dynamic value, int indent) {
    final spaces = '  ' * indent;
    
    if (value is Map<String, dynamic>) {
      final buffer = StringBuffer();
      buffer.writeln('{');
      
      final entries = value.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('$spaces  "${entry.key}": ${_formatJsonValue(entry.value, indent + 1)}');
        if (i < entries.length - 1) {
          buffer.write(',');
        }
        buffer.writeln();
      }
      
      buffer.write('$spaces}');
      return buffer.toString();
    } else if (value is List) {
      final buffer = StringBuffer();
      buffer.writeln('[');
      
      for (int i = 0; i < value.length; i++) {
        buffer.write('$spaces  ${_formatJsonValue(value[i], indent + 1)}');
        if (i < value.length - 1) {
          buffer.write(',');
        }
        buffer.writeln();
      }
      
      buffer.write('$spaces]');
      return buffer.toString();
    } else if (value is String) {
      return '"${value.replaceAll('"', '\\"')}"';
    } else {
      return value.toString();
    }
  }

  Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  String getFileName(String filePath) {
    return filePath.split('/').last;
  }
}
