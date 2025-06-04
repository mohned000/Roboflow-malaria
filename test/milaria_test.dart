import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/services/api.dart';

void main() {
  test('تحقق من استجابة الخادم', () async {
    final result = await ApiService().analyzeImage('sample.jpg');
    expect(result.containsKey('result'), true);
  });
}
