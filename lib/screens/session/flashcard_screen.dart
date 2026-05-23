import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/word.dart';
import '../../store/app_store.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});
  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Word> _words = [];
  int _index = 0;
  bool _revealed = false;
  bool _loading = true;
  int _correct = 0;
  int _wrong = 0;
  int _countdown = 10;
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
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 10;
    _revealed = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _revealed || _index >= _words.length) return false;
      setState(() => _countdown--);
      if (_countdown <= 0) { setState(() => _revealed = true); return false; }
      return true;
    });
  }

  void _answer(bool knew) {
    final word = _words[_index];
    context.read<AppStore>().updateMastery(word.id!, knew);
    if (knew) { _correct++; } else { _wrong++; }
    setState(() { _index++; _revealed = false; });
    if (_index < _words.length) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: Color(0xFF0F0F1A), body: Center(child: CircularProgressIndicator()));

    if (_index >= _words.length) {
      final secs = DateTime.now().difference(_startTime).inSeconds;
      return _ResultScreen(correct: _correct, wrong: _wrong, total: _words.length, seconds: secs);
    }

    final word = _words[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => context.pop()),
        title: Text('${_index + 1} / ${_words.length}', style: const TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: CircleAvatar(
              backgroundColor: _countdown <= 3 ? const Color(0xFFEF4444) : const Color(0xFF7C3AED),
              child: Text('$_countdown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _index / _words.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => setState(() => _revealed = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _revealed
                        ? [const Color(0xFF1E3A5F), const Color(0xFF1A1A2E)]
                        : [const Color(0xFF2D1B69), const Color(0xFF1A1A2E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _revealed ? const Color(0xFF4F46E5) : const Color(0xFF7C3AED), width: 2),
                ),
                child: Column(
                  children: [
                    Text(word.english, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    if (word.pronunciation != null)
                      Text(word.pronunciation!, style: const TextStyle(color: Colors.white54, fontSize: 16)),
                    if (!_revealed)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('👆 Tarjimani ko\'rish uchun bosing', style: TextStyle(color: Colors.white38, fontSize: 14)),
                      ),
                    if (_revealed) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),
                      Text(word.uzbek, style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 26, fontWeight: FontWeight.w600)),
                      if (word.example != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(word.example!, style: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_revealed) Row(
              children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _answer(false),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('Bilmadim', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                )),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _answer(true),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Bildim', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                )),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int correct, wrong, total, seconds;
  const _ResultScreen({required this.correct, required this.wrong, required this.total, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct / total * 100).round();
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(pct >= 70 ? '🎉' : '💪', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
              Text('${seconds}s ichida', style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _ResultChip('✅ $correct', const Color(0xFF059669)),
                const SizedBox(width: 12),
                _ResultChip('❌ $wrong', const Color(0xFFEF4444)),
              ]),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Bosh sahifaga', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String text;
  final Color color;
  const _ResultChip(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
  );
}
