import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_store.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Statistika', style: TextStyle(color: Colors.white))),
      body: Consumer<AppStore>(
        builder: (context, store, _) {
          final stats = store.stats;
          final total = stats['total'] ?? 0;
          final mastered = stats['mastered'] ?? 0;
          final addedToday = stats['addedToday'] ?? 0;
          final streak = store.todayProgress?.streakDay ?? 0;
          final pct = total == 0 ? 0.0 : mastered / total;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _BigStat(emoji: '🔥', value: '$streak', label: 'Kun ketma-ket'),
                const SizedBox(height: 16),
                Row(children: [
                  _SmallStat('📚', '$total', 'Jami so\'zlar'),
                  const SizedBox(width: 12),
                  _SmallStat('✅', '$mastered', 'O\'zlashtirilgan'),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _SmallStat('📅', '$addedToday', 'Bugun qo\'shildi'),
                  const SizedBox(width: 12),
                  _SmallStat('🎯', '${(pct * 100).toInt()}%', 'Muvaffaqiyat'),
                ]),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    const Text('O\'zlashtirish darajasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)), minHeight: 14)),
                    const SizedBox(height: 8),
                    Text('$mastered / $total so\'z o\'zlashtirildi', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String emoji, value, label;
  const _BigStat({required this.emoji, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)]), borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 40)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70)),
    ]),
  );
}

class _SmallStat extends StatelessWidget {
  final String emoji, value, label;
  const _SmallStat(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  ));
}
