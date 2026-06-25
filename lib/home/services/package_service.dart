import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class PackageService {
  final String zipUrl = 'https://tech-lms.adurox.com/flutter/player.zip';

  Future<String?> downloadAndProcessPackage({
    Function(String status, double? progress)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/lms_player');
      final indexPath = '${targetDir.path}/index.html';
      final decryptedVideoPath = '${targetDir.path}/media/video/video2.mp4';

      if (await File(indexPath).exists() && await File(decryptedVideoPath).exists()) {
        onProgress?.call("Loading local cache...", 1.0);
        return indexPath;
      }

      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
      }
      await targetDir.create(recursive: true);

      onProgress?.call("Connecting to server...", 0.0);
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(zipUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) throw Exception("Failed to download ZIP");

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      List<int> bytes = [];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call("Downloading...", receivedBytes / totalBytes);
        } else {
          onProgress?.call("Downloading...", null);
        }
      }

      onProgress?.call("Extracting files...", null);
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('${targetDir.path}/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('${targetDir.path}/$filename').createSync(recursive: true);
        }
      }

      onProgress?.call("Decrypting secure media...", null);
      await _decryptMediaFile(targetDir.path);

      onProgress?.call("Ready!", 1.0);
      return indexPath;
    } catch (e) {
      print("Error processing package: $e");
      return null;
    }
  }

  Future<void> _decryptMediaFile(String dirPath) async {
    final configFile = File('$dirPath/config.json');
    if (!await configFile.exists()) return;

    final configString = await configFile.readAsString();
    final config = jsonDecode(configString);

    final String encryptedFilePath = config['encrypted_media'][0];
    final String keyHex = config['aes']['key'];
    final String ivHex = config['aes']['iv'];

    final mediaFile = File('$dirPath/$encryptedFilePath');
    if (!await mediaFile.exists()) return;

    final encryptedBytes = await mediaFile.readAsBytes();

    final key = encrypt.Key.fromBase16(keyHex);
    final iv = encrypt.IV.fromBase16(ivHex);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

    await mediaFile.writeAsBytes(decryptedBytes);
  }
}