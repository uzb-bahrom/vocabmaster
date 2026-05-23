import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/word.dart';
import '../../store/app_store.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Word> _words = [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  int? _selected;
  bool _answered = false;
  int _countdown = 15;
  List<String> _options = [];
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
    await _loadOptions();
    _startCountdown();
  }

  Future<void> _loadOptions() async {
    if (_index >= _words.length) return;
    final current = _words[_index];
    final randoms = await context.read<AppStore>().getRandomOptions(3, excludeId: current.id);
    final opts = [current.uzbek, ...randoms.map((w) => w.uzbek)]..shuffle();
    setState(() => _options = opts);
  }

  void _startCountdown() {
    _countdown = 15;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _answered || _index >= _words.length) return false;
      setState(() => _countdown--);
      if (_countdown <= 0) { _checkAnswer(null); return false; }
      return true;
    });
  }

  void _checkAnswer(int? idx) {
    if (_answered) return;
    setState(() { _selected = idx; _answered = true; });
    final correct = idx != null && _options[idx] == _words[_index].uzbek;
    if (correct) _correct++;
    context.read<AppStore>().updateMastery(_words[_index].id!, correct);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() { _index++; _answered = false; _selected = null; });
      if (_index < _words.length) { _loadOptions(); _startCountdown(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: Color(0xFF0F0F1A), body: Center(child: CircularProgressIndicator()));
    if (_index >= _words.length) {
      final secs = DateTime.now().difference(_startTime).inSeconds;
      final wrong = _words.length - _correct;
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_correct / _words.length >= 0.7 ? '🏆' : '💪', style: const TextStyle(fontSize: 72)),
          Text('${(_correct / _words.length * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
          Text('${secs}s', style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _chip('✅ $_correct', const Color(0xFF059669)),
            const SizedBox(width: 12),
            _chip('❌ $wrong', const Color(0xFFEF4444)),
          ]),
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
        actions: [Padding(padding: const EdgeInsets.all(14), child: CircleAvatar(backgroundColor: _countdown <= 5 ? const Color(0xFFEF4444) : const Color(0xFF7C3AED), child: Text('$_countdown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: _index / _words.length, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5))),
            const SizedBox(height: 30),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                const Text('Tarjimasi qaysi?', style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 12),
                Text(word.english, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                if (word.pronunciation != null) Text(word.pronunciation!, style: const TextStyle(color: Colors.white38)),
              ]),
            ),
            const SizedBox(height: 24),
            ..._options.asMap().entries.map((e) {
              final i = e.key; final opt = e.value;
              final isCorrect = opt == word.uzbek;
              Color bg = const Color(0xFF1A1A2E);
              Color border = Colors.white12;
              if (_answered) {
                if (isCorrect) { bg = const Color(0xFF059669).withValues(alpha: 0.2); border = const Color(0xFF059669); }
                else if (_selected == i) { bg = const Color(0xFFEF4444).withValues(alpha: 0.2); border = const Color(0xFFEF4444); }
              }
              return GestureDetector(
                onTap: _answered ? null : () => _checkAnswer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 2)),
                  child: Row(children: [
                    Expanded(child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 16))),
                    if (_answered && isCorrect) const Icon(Icons.check_circle, color: Color(0xFF059669)),
                    if (_answered && !isCorrect && _selected == i) const Icon(Icons.cancel, color: Color(0xFFEF4444)),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: c)),
    child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18)),
  );
}
