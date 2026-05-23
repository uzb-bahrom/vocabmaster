import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/word.dart';
import '../../store/app_store.dart';

class TypingScreen extends StatefulWidget {
  const TypingScreen({super.key});
  @override
  State<TypingScreen> createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  List<Word> _words = [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  bool _answered = false;
  bool? _isCorrect;
  final _ctrl = TextEditingController();
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await context.read<AppStore>().getSessionWords();
    setState(() { _words = words..shuffle(); _loading = false; });
  }

  void _check() {
    final word = _words[_index];
    final input = _ctrl.text.trim().toLowerCase();
    final correct = word.uzbek.toLowerCase().trim();
    final ok = input == correct;
    setState(() { _answered = true; _isCorrect = ok; });
    if (ok) _correct++;
    context.read<AppStore>().updateMastery(word.id!, ok);
  }

  void _next() {
    setState(() { _index++; _answered = false; _isCorrect = null; _ctrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: Color(0xFF0F0F1A), body: Center(child: CircularProgressIndicator()));
    if (_index >= _words.length) {
      final secs = DateTime.now().difference(_startTime).inSeconds;
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_correct / _words.length >= 0.7 ? '🏆' : '💪', style: const TextStyle(fontSize: 72)),
          Text('${(_correct / _words.length * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
          Text('${secs}s', style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => context.go('/'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Bosh sahifaga', style: TextStyle(color: Colors.white))),
        ])),
      );
    }

    final word = _words[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => context.pop()),
        title: Text('${_index + 1} / ${_words.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: _index / _words.length, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF059669))),
            const SizedBox(height: 30),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                const Text('O\'zbekcha tarjimasini yozing', style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 12),
                Text(word.english, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                if (word.example != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(word.example!, style: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic), textAlign: TextAlign.center)),
              ]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _ctrl,
              enabled: !_answered,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                hintText: 'O\'zbekcha yozing...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: _answered
                    ? (_isCorrect! ? const Color(0xFF059669).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.15))
                    : const Color(0xFF1A1A2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF059669))),
                suffixIcon: _answered
                    ? Icon(_isCorrect! ? Icons.check_circle : Icons.cancel, color: _isCorrect! ? const Color(0xFF059669) : const Color(0xFFEF4444))
                    : null,
              ),
              onSubmitted: (_) => _answered ? _next() : _check(),
            ),
            if (_answered && !_isCorrect!) Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4))),
                child: Row(children: [
                  const Icon(Icons.lightbulb, color: Color(0xFF059669), size: 18),
                  const SizedBox(width: 8),
                  Text('To\'g\'ri javob: ${word.uzbek}', style: const TextStyle(color: Color(0xFF86EFAC), fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _answered ? _next : _check,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answered ? const Color(0xFF4F46E5) : const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_answered ? 'Keyingisi →' : 'Tekshirish', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}
