import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart'; 

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

  
  Future<bool> downloadModel({required Function(double) onProgress}) async {
    try {
      final savePath = await getLocalPath();
      await Dio().download(fileUrl, savePath, onReceiveProgress: (rec, total) {
        if (total != -1) onProgress(rec / total);
      });
      
     
      if (await File(savePath).length() > 0) {
        return true; 
      } else {
        return false; 
      }
    } catch (e) {
      print("Download Error: $e");
      return false; 
    }
  }

  
  Future<bool> importModelFromDevice() async {
    try {
     
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        File sourceFile = File(result.files.single.path!);
        String destPath = await getLocalPath();
        

        await sourceFile.copy(destPath);
        
         
        if (await File(destPath).exists()) {
          return true;
        }
      }
      return false; 
    } catch (e) {
      print("Import Error: $e");
      return false;
    }
  }
}
