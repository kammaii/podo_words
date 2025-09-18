import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


class ImageController {
  final Map<String, String> _localImagePaths = {};

  // 이미지를 디코딩하여 로컬 파일로 캐싱하는 함수
  Future<void> cacheImageFiles(List<dynamic> items) async {
    final tempDir = await getTemporaryDirectory();
    final p = path.join(tempDir.path, 'images');
    final dir = Directory(p);
    if(!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final List<Future<void>> cachingFutures = [];

    for (final item in items) {
      if (item.image != null && item.image!.isNotEmpty) {
        final cachingTask = () async {
          try {
            final localPath = path.join(p, '${item.id}.png');
            final file = File(localPath);
            if (!await file.exists()) {
              // Base64 문자열을 디코딩하여 바이트로 변환
              final imageBytes = base64Decode(item.image!);
              // 디코딩된 바이트를 파일로 저장
              await file.writeAsBytes(imageBytes);
            }
            _localImagePaths[item.id] = localPath;
          } catch (e) {
            debugPrint('이미지 캐싱 실패 (Item ID: ${item.id}): $e');
          }
        };
        cachingFutures.add(cachingTask());
      }
    }
    await Future.wait(cachingFutures);
  }

  Image getCachedImage(String id, {Color? color}) {
    final localPath = _localImagePaths[id];

    // 캐시된 로컬 경로가 있으면 Image.file을 사용 (매우 빠름)
    if (localPath != null) {
      return Image.file(
        File(localPath),
        fit: BoxFit.fitWidth,
        color: color,
      );
    }
    // 캐시된 경로가 없으면 (이미지가 없는 단어 등) 투명 이미지를 표시
    else {
      print('이미지 없음');
      return Image.asset('assets/images/transparent.png', fit: BoxFit.fitWidth);
    }
  }
}