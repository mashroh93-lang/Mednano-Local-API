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
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return 'خطأ في قراءة الصورة';

      // 1. تغيير الحجم للـ Input بتاع الموديل
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // 2. تحويل الصورة لمصفوفة (Normalization)
      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              // تقسيم على 255 لتحويل القيم لـ 0.0 - 1.0
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            },
          ),
        ),
      );

      // 3. إعداد مكان النتيجة (الـ 7 أصناف بتوعنا)
      var outputData = List.filled(1 * 7, 0.0).reshape([1, 7]);

      // 4. تشغيل الموديل (تأكد إننا بنستخدم outputData مش output)
      _interpreter!.run(input, outputData);

      // 5. استخراج النتيجة
      List<double> probabilities = List<double>.from(outputData[0]);
      int maxIndex = 0;
      double maxProb = -1.0;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // 6. قائمة الـ 7 أمراض الحقيقية الخاصة بموديل HAM10000
      List<String> diseases = [
        'تقران سفعي (Actinic Keratosis)',
        'سرطان الخلايا القاعدة (Basal Cell Carcinoma)',
        'آفات حميدة (Benign Keratosis)',
        'ورم ليفي جلدي (Dermatofibroma)',
        'شامات صبغية (Melanocytic Nevi)',
        'ميلانوما (Melanoma)',
        'آفات وعائية (Vascular lesions)'
      ];

      double confidence = maxProb * 100;
      return 'التشخيص: ${diseases[maxIndex]}\nالدقة: ${confidence.toStringAsFixed(1)}%';

    } catch (e) {
      return 'خطأ في المعالجة: $e';
    }
  }
