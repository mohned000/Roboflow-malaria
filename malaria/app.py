from flask import Flask, request, jsonify
from PIL import Image
import io
import base64
import socket
from ultralytics import YOLO
import numpy as np

# تحميل النموذج
model = YOLO('best.pt')  # تأكد من أن best.pt في نفس المجلد أو استخدم المسار الكامل

app = Flask(__name__)

@app.route('/')
def home():
    return "الخادم يعمل بنجاح."

@app.route('/analyze', methods=['POST'])
def analyze():
    if 'file' not in request.files:
        return jsonify({"error": "لم يتم إرسال صورة"}), 400

    file = request.files['file']
    image = Image.open(file.stream).convert('RGB')

    # تحويل الصورة إلى NumPy array
    img_np = np.array(image)

    # تحليل الصورة باستخدام YOLOv8
    results = model(img_np)

    # استخراج التسميات
    labels = results[0].names
    detected_classes = [labels[int(cls)] for cls in results[0].boxes.cls]

    # التشخيص
    diagnosis = "مصاب بالملاريا" if 'malaria' in detected_classes else "سليم"

    # رسم النتائج على الصورة
    annotated_img = results[0].plot()  # تعطي الصورة مع المربعات مرسومة

    # تحويل الصورة إلى base64
    img_pil = Image.fromarray(annotated_img)
    img_io = io.BytesIO()
    img_pil.save(img_io, 'JPEG')
    img_io.seek(0)
    img_base64 = base64.b64encode(img_io.read()).decode('utf-8')

    return jsonify({
        "diagnosis": f"النتيجة: {diagnosis}",
        "image_base64": img_base64
    })

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

if __name__ == '__main__':
    ip = get_ip()
    print(f"السيرفر يعمل على: http://{ip}:5000")
    app.run(host='0.0.0.0', port=5000)