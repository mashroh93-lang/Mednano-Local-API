import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class VisionHelper {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mednano_vision.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<String> predictImage(File imageFile) async {
    if (_interpreter == null) {
      return 'الموديل غير محمل';
    }

    try {
      // قراءة الصورة
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        return 'خطأ في قراءة الصورة';
      }

      // تغيير حجم الصورة إلى 224x224 (افتراضي لمعظم الموديلات)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // تحويل إلى RGB إذا لزم الأمر
      if (resizedImage.numChannels == 4) {
        resizedImage = img.copyResize(resizedImage, width: 224, height: 224);
      }

      // تحويل إلى tensor
      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => List.generate(
              3,
              (c) => resizedImage.getPixel(x, y)[c] / 255.0, // normalize
            ),
          ),
        ),
      );

      // إعداد output
      var outputData = List.filled(1 * 7, 0.0).reshape([1, 7]);

      // تشغيل الموديل
      _interpreter!.run(input, output);

      // الحصول على النتيجة (أعلى احتمالية)
      List<double> probabilities = output[0];
      int maxIndex = probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

      // قائمة الأمراض (مثال، يجب استبدالها بالحقيقية)
      List<String> diseases = [
        'جلد طبيعي',
        'إكزيما',
        'صدفية',
        'حساسية',
        'سرطان الجلد',
        // أضف المزيد حسب الموديل
      ];

      if (maxIndex < diseases.length) {
        return 'تشخيص محتمل: ${diseases[maxIndex]}';
      } else {
        return 'تشخيص: حالة غير معروفة';
      }
    } catch (e) {
      return 'خطأ في المعالجة: $e';
    }
  }
}
