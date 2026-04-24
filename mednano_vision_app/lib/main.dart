import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'vision_helper.dart'; // استدعاء العقل البصري بتاعنا

void main() {
  runApp(const MednanoApp());
}

class MednanoApp extends StatelessWidget {
  const MednanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mednano Vision',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const VisionScreen(),
    );
  }
}

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  // تعريف العين وأداة سحب الصور
  final VisionHelper _visionHelper = VisionHelper();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  String _diagnosisResult = "جاهز لفحص الجلد... اضغط على الكاميرا";

  @override
  void initState() {
    super.initState();
    // تشغيل العين أول ما الشاشة تفتح عشان تكون جاهزة في الذاكرة
    _visionHelper.loadModel();
  }

  // دالة فتح الكاميرا أو الاستوديو
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _diagnosisResult = "جاري الفحص الدقيق... ⏳";
      });

      // إرسال الصورة للعين والانتظار لأجزاء من الثانية
      String result = await _visionHelper.predictImage(_selectedImage!);
      
      setState(() {
        _diagnosisResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mednano - فحص الجلد 👁️', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // مربع عرض الصورة الملقطة
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.teal, width: 3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ]
                ),
                child: _selectedImage == null
                    ? const Icon(Icons.health_and_safety_outlined, size: 100, color: Colors.teal)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(height: 40),
              
              // عرض نتيجة التشخيص البصري
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _diagnosisResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // زراير التحكم (كاميرا / استوديو)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('لقطة جديدة', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('من المعرض', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}