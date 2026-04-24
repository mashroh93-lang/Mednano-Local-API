import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class VisionHelper {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mednano_vision.tflite');
      print('Model Loaded');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> predictImage(File imageFile) async {
    if (_interpreter == null) return 'الموديل غير محمل';
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return 'خطأ في الصورة';

      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
      })));

      var outputData = List.filled(1 * 7, 0.0).reshape([1, 7]);
      _interpreter!.run(input, outputData);

      List<double> probs = List<double>.from(outputData[0]);
      int maxIdx = 0;
      double maxVal = -1.0;
      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > maxVal) {
          maxVal = probs[i];
          maxIdx = i;
        }
      }

      List<String> labels = ['تقران سفعي', 'سرطان خلايا قاعدة', 'آفات حميدة', 'ورم ليفي', 'شامات صبغية', 'ميلانوما', 'آفات وعائية'];
      return 'التشخيص: ${labels[maxIdx]}\nالدقة: ${(maxVal * 100).toStringAsFixed(1)}%';
    } catch (e) {
      return 'خطأ: $e';
    }
  }
}
