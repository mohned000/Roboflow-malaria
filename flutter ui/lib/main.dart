import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // مهم للوصول إلى مجلد آمن
import 'package:path/path.dart'; // لاستخلاص اسم الملف

void main() {
  runApp(const MalariaApp());
}

class MalariaApp extends StatelessWidget {
  const MalariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malaria Detector',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const DetectionPage(),
    );
  }
}

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  File? _image;
  String? _resultText;
  String? _base64Image;
  String _ip = "192.168.1.100";
  String _port = "5000";

  final picker = ImagePicker();
  final ipController = TextEditingController();
  final portController = TextEditingController();

  Future<void> _getImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      File imageFile;

      if (source == ImageSource.camera) {
        // نسخ الصورة إلى مجلد مؤقت آمن
        final tempDir = await getTemporaryDirectory();
        final newPath = join(tempDir.path, basename(picked.path));
        imageFile = await File(picked.path).copy(newPath);
      } else {
        // إذا من المعرض نأخذ المسار مباشرة
        imageFile = File(picked.path);
      }

      setState(() {
        _image = imageFile;
        _resultText = null;
        _base64Image = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    var uri = Uri.parse("http://$_ip:$_port/analyze");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);

      setState(() {
        _resultText = json["diagnosis"];
        _base64Image = json["image_base64"];
      });
    } else {
      setState(() {
        _resultText = "فشل الاتصال بالخادم.";
      });
    }
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تشخيص الملاريا')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(labelText: "عنوان IP"),
              onChanged: (val) => _ip = val,
            ),
            TextField(
              controller: portController,
              decoration: const InputDecoration(labelText: "المنفذ PORT"),
              onChanged: (val) => _port = val,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: const Text("رفع صورة")),
                ElevatedButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    child: const Text("كاميرا")),
              ],
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("لم يتم اختيار صورة"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _analyzeImage,
              child: const Text("تشخيص"),
            ),
            const SizedBox(height: 20),
            if (_resultText != null) Text("النتيجة: $_resultText"),
            const SizedBox(height: 10),
            if (_base64Image != null)
              Image.memory(base64Decode(_base64Image!), height: 200)
            else if (_resultText != null)
              const Text("لم يتم تحميل صورة النتائج."),
          ],
        ),
      ),
    );
  }
}
