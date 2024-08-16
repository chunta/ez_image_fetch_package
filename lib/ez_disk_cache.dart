import 'dart:typed_data';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EzDiskCache {
  final Directory _cacheDir;

  EzDiskCache({String? customPath})
      : _cacheDir = Directory(customPath ?? Directory.systemTemp.path);

  String _getCacheFilePath(String url) {
    final fileName = _generateFileNameFromUrl(url);
    return '${_cacheDir.path}/$fileName';
  }

  String _generateFileNameFromUrl(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void save(String url, Uint8List data) {
    final file = File(_getCacheFilePath(url));
    file.writeAsBytesSync(data);
  }

  Uint8List? get(String url) {
    final file = File(_getCacheFilePath(url));
    if (file.existsSync()) {
      return file.readAsBytesSync();
    }
    return null;
  }

  void remove(String url) {
    final file = File(_getCacheFilePath(url));
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  void clear() {
    final cacheFiles = _cacheDir.listSync();
    for (var file in cacheFiles) {
      if (file is File) {
        file.deleteSync();
      }
    }
  }
}
