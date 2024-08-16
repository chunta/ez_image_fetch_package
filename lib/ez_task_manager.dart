import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EzRunningTaskPair {
  final String _url;
  final CancelToken _cancelToken;

  EzRunningTaskPair({required String url, required CancelToken cancelToken})
      : _url = url,
        _cancelToken = cancelToken;

  String url() => _url;

  void cancel() => _cancelToken.cancel();
}

class EzTaskManager {
  final Map<String, Uint8List> imageCache = {};
  final Map<String, Future<Image>> fetchingImages = {};
  final List<EzRunningTaskPair> runningUrlQueue = [];
  final int maxRunningTask;

  EzTaskManager({required this.maxRunningTask});

  void manageRunningTasks() {
    final dif = runningUrlQueue.length - maxRunningTask;
    if (dif > 0) {
      for (var i = 0; i < dif; i++) {
        EzRunningTaskPair pair = runningUrlQueue[i];
        pair.cancel();

        imageCache.remove(pair.url());
        runningUrlQueue.removeAt(i);
      }
    }
  }
}
