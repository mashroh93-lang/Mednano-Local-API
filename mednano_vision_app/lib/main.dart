import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'vision_helper.dart';
import 'download_service.dart';

void main() => runApp(const MaterialApp(home: HomeScreen(), debugShowCheckedModeBanner: false));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VisionHelper _vision = VisionHelper();
  final DownloadService _download = DownloadService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String _result = "جاهز للفحص...";
  bool _isModelReady = false;
  bool _isDownloading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkBrain();
    _vision.loadModel();
  }

  Future<void> _checkBrain() async {
    bool exists = await _download.isModelDownloaded();
    setState(() => _isModelReady = exists);
  }

  // كود تشغيل الكاميرا الفعلي 📸
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "جاري التحليل...";
      });
      String prediction = await _vision.predictImage(_image!);
      setState(() => _result = prediction);
    }
  }

  // 🔴 الدالة اللي كانت ناقصة لمعالجة التحميل من الإنترنت بشكل صحيح
  Future<void> _startDownload() async {
    setState(() => _isDownloading = true);
    
    bool success = await _download.downloadModel(onProgress: (p) => setState(() => _progress = p));
    
    if (success) {
      setState(() { _isDownloading = false; _isModelReady = true; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم التحميل بنجاح! ✅")));
      }
    } else {
      setState(() { _isDownloading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل التحميل، يرجى التحقق من الإنترنت أو مساحة الهاتف!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // كارت التشخيص والرؤية (Vision)
              _buildModernCard(
                title: "فحص الجلد الذكي",
                child: Column(
                  children: [
                    Container(
                      height: 200, width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white, border: Border.all(color: Colors.teal, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _image == null 
                        ? const Icon(Icons.shield_moon, size: 80, color: Colors.teal) 
                        : ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(_image!, fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 15),
                    Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera), label: const Text("كاميرا")),
                        ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo), label: const Text("المعرض")),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // كارت المساعد الطبي (التحميل والاستيراد)
              _buildModernCard(
                title: "المساعد الطبي (AI Chat)",
                child: _isModelReady 
                  ? _buildSuccessView() 
                  : _buildDownloadView(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({required String title, required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const Divider(),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // واجهة أزرار التحميل
  Widget _buildDownloadView() {
    return Column(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
        const Text("العقل الطبي غير موجود محلياً", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 15),
        
        if (_isDownloading)
          Column(children: [
            LinearProgressIndicator(value: _progress), 
            const SizedBox(height: 5),
            Text("${(_progress * 100).toStringAsFixed(1)}%")
          ])
        else
          Column(
            children: [
              // زرار التحميل من الإنترنت
              ElevatedButton.icon(
                onPressed: _startDownload, // الدالة شغالة تمام هنا
                icon: const Icon(Icons.cloud_download), 
                label: const Text("تحميل من الإنترنت (1.24GB)"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              ),
              const SizedBox(height: 10),
              
              // زرار الاستيراد من الهاتف
              OutlinedButton.icon(
                onPressed: () async {
                  setState(() => _isDownloading = true);
                  bool success = await _download.importModelFromDevice();
                  if (success) {
                    setState(() { _isDownloading = false; _isModelReady = true; });
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم استيراد العقل بنجاح! ✅")));
                  } else {
                    setState(() => _isDownloading = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لم يتم الاستيراد.")));
                  }
                },
                icon: const Icon(Icons.folder_copy), 
                label: const Text("استيراد العقل من الهاتف 📁"),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 40),
        const Text("العقل الطبي مفعل وجاهز", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () {}, child: const Text("فتح الدردشة الطبية")),
      ],
    );
  }
}
