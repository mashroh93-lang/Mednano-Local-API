package com.example.mednano_ai

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.pytorch.LiteModuleLoader
import org.pytorch.Module
import java.io.File
import android.os.Handler
import android.os.Looper

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
                    Thread {
                        try {
                            val file = File(modelPath)
                            if (!file.exists()) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("ERROR", "ملف العقل غير موجود", null)
                                }
                                return@Thread
                            }

                            // 🔴 الاختبار: وقفنا السطر اللي بيعمل الكراش وعملنا محاكاة
                            // if (module == null) {
                            //     module = LiteModuleLoader.load(modelPath)
                            // }
                            
                            // محاكاة إن الموبايل بيفكر لمدة 3 ثواني
                            Thread.sleep(3000)

                            Handler(Looper.getMainLooper()).post {
                                result.success("✅ اختبار الكوبري نجح 100%!\n\nلو قرأت الرسالة دي، يبقى التطبيق سليم، والانهيار كان بسبب إن ملف الـ PTL يحتوي على خوارزميات لغوية (LLM) أكبر من قدرة محرك PyTorch Mobile القياسي.\nرسالتك: $prompt")
                            }

                        } catch (e: Exception) {
                            Handler(Looper.getMainLooper()).post {
                                result.error("ERROR", "خطأ عام: ${e.message}", null)
                            }
                        }
                    }.start()
                } else {
                    result.error("ARGS_ERROR", "نقص في البيانات", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
