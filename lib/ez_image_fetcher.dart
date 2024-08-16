import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'ez_disk_cache.dart';
import 'ez_task_manager.dart';

class EzImageFetcher {
  final Dio dio;
  final EzDiskCache diskCache;
  final EzTaskManager taskManager;
  final Image errorImage;
  final Logger? logger;

  EzImageFetcher(
      {required this.dio,
      required this.diskCache,
      required this.taskManager,
      required this.errorImage,
      this.logger});

  Future<Image> fetchImage(String url) async {
    if (taskManager.imageCache.containsKey(url)) {
      logger?.i("$url get from memory cache");
      return Image.memory(taskManager.imageCache[url]!);
    }

    final cacheData = diskCache.get(url);
    if (cacheData != null) {
      logger?.i("$url get from disk cache");
      taskManager.imageCache[url] = cacheData;
      return Image.memory(cacheData);
    }

    if (taskManager.fetchingImages.containsKey(url)) {
      logger?.i("$url is currently being fetched");
      return await taskManager.fetchingImages[url]!;
    }

    CancelToken cancelToken = CancelToken();

    final future = (() async {
      try {
        final response = await dio.get(
          url,
          cancelToken: cancelToken,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to load image: ${response.statusCode}');
        }

        final Uint8List bytes = response.data;

        taskManager.imageCache[url] = bytes;
        diskCache.save(url, bytes);

        return Image.memory(bytes);
      } catch (e) {
        return errorImage;
      } finally {
        taskManager.fetchingImages.remove(url);
      }
    })();

    taskManager.fetchingImages[url] = future;
    taskManager.runningUrlQueue
        .add(EzRunningTaskPair(url: url, cancelToken: cancelToken));

    taskManager.manageRunningTasks();
    return await future;
  }
}
