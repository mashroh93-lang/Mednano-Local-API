from fastapi import FastAPI
from pydantic import BaseModel
import torch

app = FastAPI(title="Mednano AI Doctor API")

# تحميل الموديل (هيفضل معلق لحد ما نرفع ملف الـ .pt بعدين)
model_path = "Mednano_AI_Doctor.pt"
model = None

try:
    # بنجهزه عشان يقرأ الملف أول ما يكمل تحميل
    model = torch.jit.load(model_path, map_location='cpu')
    print("✅ الطبيب الآلي جاهز في العيادة!")
except Exception as e:
    print(f"⚠️ في انتظار وصول الطبيب (الملف لم يكتمل بعد)...")

# شكل الداتا اللي التطبيق بتاعك هيبعتها
class PatientData(BaseModel):
    symptoms: str

# مسار التشخيص
@app.post("/diagnose")
async def diagnose_patient(data: PatientData):
    if model is None:
        return {"error": "الموديل غير متاح حالياً."}
    
    # هنا هنحط لوجيك تشغيل الموديل على الأعراض
    # مؤقتاً هنخليه يرد برسالة تأكيد لحد ما نربط الـ C++
    return {
        "status": "success",
        "doctor_reply": f"تم استلام حالة المريض: {data.symptoms}. جاري المعالجة محلياً..."
    }