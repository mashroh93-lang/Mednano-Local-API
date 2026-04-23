import torch
from torch.utils.mobile_optimizer import optimize_for_mobile

print("⚙️ جاري تحويل العقل لنسخة الموبايل (Edge AI)...")

try:
    # 1. تحميل الموديل الأساسي
    print("Loading model...")
    model = torch.jit.load("Mednano_AI_Doctor.pt", map_location='cpu')
    print("Model loaded successfully")
    
    # 2. تحسين الموديل ليناسب معالجات الموبايل (ARM)
    print("Optimizing for mobile...")
    optimized_model = optimize_for_mobile(model)
    print("Optimization done")
    
    # 3. حفظ النسخة الجديدة
    mobile_model_path = "mednano_edge.ptl"
    print("Saving...")
    optimized_model._save_for_lite_interpreter(mobile_model_path)
    
    print(f"✅ تم بنجاح! الملف الجديد جاهز للدمج في التطبيق: {mobile_model_path}")
except Exception as e:
    print(f"❌ حدث خطأ: {e}")