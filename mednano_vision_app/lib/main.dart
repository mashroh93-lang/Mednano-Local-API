import 'dart:io';
import 'package:flutter/material.dart';
import 'vision_helper.dart';
import 'download_service.dart';

void main() {
  runApp(const MednanoAI());
}

class MednanoAI extends StatelessWidget {
  const MednanoAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mednano AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VisionHelper _visionHelper = VisionHelper();
  final DownloadService _downloadService = DownloadService();
  
  bool _isModelReady = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _statusMessage = "جاري الفحص...";

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // الفحص الذكي: هل العقل موجود في الذاكرة؟
  Future<void> _checkStatus() async {
    bool downloaded = await _downloadService.isModelDownloaded();
    await _visionHelper.loadModel(); // تحميل موديل الجلد (الصغير) دايماً
    
    setState(() {
      _isModelReady = downloaded;
      _statusMessage = downloaded ? "النظام جاهز" : "العقل اللغوي غير مفعل";
    });
  }

  // عملية التحميل (بتحصل مرة واحدة في العمر)
  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = "جاري تحميل العقل الطبي (1.24 جيجا)...";
    });

    await _downloadService.downloadModel(onProgress: (progress) {
      setState(() {
        _downloadProgress = progress;
      });
    });

    setState(() {
      _isDownloading = false;
      _isModelReady = true;
      _statusMessage = "تم التفعيل بنجاح ✅";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mednano AI 🩺"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة الحالة
            Icon(
              _isModelReady ? Icons.check_circle : Icons.info_outline,
              size: 80,
              color: _isModelReady ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(_statusMessage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 40),

            // زرار فحص الجلد (شغال دايماً لأن حجمه صغير جوه التطبيق)
            _buildMenuButton(
              title: "فحص الجلد (Vision)",
              icon: Icons.camera_alt,
              color: Colors.blue,
              onPressed: () {
                // هنا نفتح الكاميرا والتشخيص اللي عملناه قبل كدة
                showDialog(context: context, builder: (context) => AlertDialog(title: Text("قريباً"), content: Text("هنا نربط كود الكاميرا")));
              },
            ),

            const SizedBox(height: 20),

            // زرار الشات (بيعتمد على التحميل)
            if (!_isModelReady && !_isDownloading)
              _buildMenuButton(
                title: "تفعيل المساعد الطبي (1.24GB)",
                icon: Icons.download,
                color: Colors.orange,
                onPressed: _startDownload,
              )
            else if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 10),
                  Text("${(_downloadProgress * 100).toStringAsFixed(1)}%"),
                ],
              )
            else
              _buildMenuButton(
                title: "تحدث مع الطبيب (Chat)",
                icon: Icons.chat,
                color: Colors.green,
                onPressed: () {
                  // هنا نفتح واجهة الشات
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({required String title, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
