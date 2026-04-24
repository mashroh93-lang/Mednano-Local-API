import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class VisionHelper {
  Interpreter? _interpreter;

  // تحميل الموديل من الـ Assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mednano_vision.tflite');
      print('تم تحميل الموديل بنجاح ✅');
    } catch (e) {
      print('خطأ في تحميل الموديل: $e');
    }
  }

  Future<String> predictImage(File imageFile) async {
    if (_interpreter == null) {
      return 'الموديل غير محمل.. جاري المحاولة مرة أخرى';
    }

    try {
      // 1. قراءة وتحليل الصورة
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return 'خطأ في قراءة الصورة ❌';

      // 2. تحويل الحجم ليتوافق مع الموديل (224x224)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // 3. تحويل بكسلات الصورة لمصفوفة Float32 (Normalization)
      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              // استخراج قيم R, G, B وتقسيمها على 255
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            },
          ),
        ),
      );

      // 4. إعداد مكان النتيجة (7 أصناف طبية)
      var outputData = List.filled(1 * 7, 0.0).reshape([1, 7]);

      // 5. تشغيل العقل البصري
      _interpreter!.run(input, outputData);

      // 6. البحث عن أعلى احتمالية من النتائج السبعة
      List<double> probabilities = List<double>.from(outputData[0]);
      int maxIndex = 0;
      double maxProb = -1.0;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // قائمة التشخيصات الخاصة بموديل HAM10000
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
      
      // النتيجة النهائية تظهر للمستخدم
      return 'التشخيص المحتمل: ${diseases[maxIndex]}\nدقة الفحص: ${confidence.toStringAsFixed(1)}%';

    } catch (e) {
      return 'خطأ تقني في المعالجة: $e';
    }
  }
} 
