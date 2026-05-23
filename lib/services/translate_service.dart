import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  static Future<String?> translateToUzbek(String word) async {
    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(word)}&langpair=en|uz',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final t = data['responseData']['translatedText'] as String?;
        if (t != null && t.isNotEmpty && t.toLowerCase() != word.toLowerCase()) {
          return t;
        }
      }
    } catch (_) {}
    return null;
  }
}
