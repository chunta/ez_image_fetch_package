import 'package:ez_image_fetch_package/ez_disk_cache.dart';
import 'package:ez_image_fetch_package/ez_image_fetcher.dart';
import 'package:ez_image_fetch_package/ez_task_manager.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

void main() {
  runApp(ExampleScreen());
}

class ExampleScreen extends StatelessWidget {
  final EzImageFetcher imageFetcher = EzImageFetcher(
    dio: Dio()
      ..httpClientAdapter = NativeAdapter(
          createCupertinoConfiguration: () =>
              URLSessionConfiguration.ephemeralSessionConfiguration()),
    diskCache: EzDiskCache(),
    taskManager: EzTaskManager(maxRunningTask: 44),
    errorImage: Image.asset("assets/dog.png"),
    logger: Logger(),
  );

  ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Image Fetch Example')),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columns in the grid
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: 51,
          itemBuilder: (context, index) {
            final imageUrl =
                'https://via.placeholder.com/200x200.png?text=$index';
            return FutureBuilder<Image>(
              future: imageFetcher.fetchImage(imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Icon(Icons.error));
                } else {
                  return snapshot.data!;
                }
              },
            );
          },
        ),
      ),
    );
  }
}
