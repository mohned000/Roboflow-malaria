# Malaria Detection App

هذا المشروع يستخدم نموذج YOLO مدرب للكشف عن الملاريا من صور خلايا الدم. الخادم يعمل باستخدام FastAPI ويُدمج مع واجهة مستخدم تم تطويرها باستخدام Flutter.

## 🧪 الوظيفة

- رفع صورة من خلال واجهة Flutter.
- تحليل الصورة عبر FastAPI باستخدام YOLO.
- عرض النتيجة على واجهة المستخدم.
  
## 🔧 التقنيات المستخدمة

| الطبقة | التقنية |
|--------|---------|
| نموذج الذكاء الاصطناعي | YOLOv5 - Roboflow Model |
| الخادم | FastAPI - Python |
| الواجهة | Flutter - Dart |
| الاتصال بين الخادم والتطبيق | HTTP API |

## 🚀 طريقة التشغيل

### المتطلبات:
- Python 3.10+
- Dart SDK 3.2+
- Flutter 3.19+
- YOLO model (exported from Roboflow)

### إعداد الخادم:
```bash
cd fastapi_server
pip install -r requirements.txt
uvicorn main:app --reload
