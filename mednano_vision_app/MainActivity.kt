package com.example.mednano_ai

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.pytorch.LiteModuleLoader
import org.pytorch.Module
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mednano.ai/pytorch"
    private var module: Module? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "generateText") {
                val prompt = call.argument<String>("prompt")
                val modelPath = call.argument<String>("modelPath")

                if (prompt != null && modelPath != null) {
                    try {
                        // 1. التأكد من وجود ملف العقل
                        val file = File(modelPath)
                        if (!file.exists()) {
                            result.error("ERROR", "ملف العقل غير موجود في المسار: $modelPath", null)
                            return@setMethodCallHandler
                        }

                        // 2. تحميل الموديل (PTL) في الرامات لأول مرة فقط
                        if (module == null) {
                            module = LiteModuleLoader.load(modelPath)
                        }

                        // 3. الرد لإثبات نجاح الاتصال وتحميل الموديل
                        result.success("✅ تم الاتصال بنجاح بمحرك PyTorch المحلي!\n\nتم تحميل العقل اللغوي بنجاح.\nسؤالك كان: $prompt\n\n(المحرك الآن جاهز لاستقبال خوارزمية الـ Tokenizer لتحليل الإجابة)")

                    } catch (e: Exception) {
                        result.error("PYTORCH_ERROR", "خطأ في محرك الذكاء الاصطناعي: ${e.message}", null)
                    }
                } else {
                    result.error("ARGS_ERROR", "البيانات المرسلة غير مكتملة", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
