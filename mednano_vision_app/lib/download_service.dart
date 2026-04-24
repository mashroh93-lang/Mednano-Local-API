import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final String fileUrl = "https://github.com/mashroh93-lang/Mednano-Local-API/releases/download/v1.0.0/mednano_edge.ptl";

  Future<String> getLocalPath() async {
    final directory = await getApplicationSupportDirectory();
    return "${directory.path}/mednano_edge.ptl";
  }

  Future<bool> isModelDownloaded() async {
    final path = await getLocalPath();
    return File(path).exists();
  }

  Future<void> downloadModel({required Function(double) onProgress}) async {
    try {
      final savePath = await getLocalPath();
      await Dio().download(fileUrl, savePath, onReceiveProgress: (rec, total) {
        if (total != -1) onProgress(rec / total);
      });
    } catch (e) {
      print("Download Error: $e");
    }
  }
}
