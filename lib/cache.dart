import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  // 🔹 이미지 변환 함수 (static으로 변경)
  static Uint8List convertImage(Uint8List imageData) {
    img.Image? image = img.decodeImage(imageData);
    if (image == null) return imageData;

    img.Image resized = img.copyResize(image, width: 300);
    return Uint8List.fromList(img.encodeJpg(resized));
  }

  // 🔹 Isolate에서 실행할 함수
  void isolateImageProcessing(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var message in receivePort) {
      if (message is Uint8List) {
        img.Image? image = img.decodeImage(message);
        if (image != null) {
          img.Image resized = img.copyResize(image, width: 300);
          Uint8List result = Uint8List.fromList(img.encodeJpg(resized));
          sendPort.send(result);
        }
      } else {
        receivePort.close(); // ⬅️ 리소스 해제
        break;
      }
    }
  }

  // 🔹 Isolate 실행 함수
  Future<Uint8List> runImageProcessing(Uint8List imageData) async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(isolateImageProcessing, receivePort.sendPort);

    SendPort sendPort = await receivePort.first as SendPort;
    ReceivePort responsePort = ReceivePort();

    sendPort.send(imageData);
    Uint8List result = await responsePort.first as Uint8List;

    isolate.kill(priority: Isolate.immediate);
    return result;
  }

  // 🔹 이미지 다운로드 및 압축 (변경 사항 포함)
  void downloadAndCompress(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var message in receivePort) {
      if (message is Map) {
        String url = message['url'];
        String fileName = message['fileName'];

        try {
          Dio dio = Dio();
          var response = await dio.get(url, options: Options(responseType: ResponseType.bytes));

          if (response.statusCode != 200) {
            sendPort.send('error');
            continue;
          }

          Uint8List imageData = Uint8List.fromList(response.data);
          img.Image? image = img.decodeImage(imageData);
          if (image != null) {
            img.Image resized = img.copyResize(image, width: 500);
            Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized));

            Directory dir = await getApplicationDocumentsDirectory();
            File file = File("${dir.path}/$fileName");

            await file.create();  // 🔹 파일 생성 추가
            await file.writeAsBytes(compressed);

            sendPort.send(file.path);
          }
        } catch (e) {
          sendPort.send('error');
        }
      }
    }
  }

  // 🔹 Isolate 실행 함수
  Future<String> fetchAndCompressImage(String imageUrl, String fileName) async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(downloadAndCompress, receivePort.sendPort);

    SendPort sendPort = await receivePort.first as SendPort;
    ReceivePort responsePort = ReceivePort();

    sendPort.send({"url": imageUrl, "fileName": fileName});
    String filePath = await responsePort.first as String;

    isolate.kill(priority: Isolate.immediate);
    return filePath;
  }

  static void preloadImage(BuildContext context, String imageUrl) {
    precacheImage(CachedNetworkImageProvider(imageUrl), context);
  }

  static void preloadImages(BuildContext context, List<String> imageUrls) {
    for (String url in imageUrls) {
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }
}