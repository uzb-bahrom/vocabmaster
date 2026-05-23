import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../store/app_store.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('O\'yin rejimi', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<AppStore>(
        builder: (context, store, _) {
          final due = store.stats['dueToday'] ?? 0;
          final total = store.stats['total'] ?? 0;

          if (total < 4) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text('Kamida 4 ta so\'z qo\'shing!', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Hozir: $total ta', style: const TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$due ta so\'z kutmoqda', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Bugun takrorlash uchun', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text('Rejim tanlang', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                _ModeCard(icon: '🃏', title: 'Flashcard', desc: 'So\'zni ko\'r → 10 sek → tarjima ochiladi', color: const Color(0xFF7C3AED), onTap: () => context.push('/session/flashcard')),
                _ModeCard(icon: '🎯', title: 'Test (4 variant)', desc: '4 javobdan to\'g\'risini tanlang, 15 sek', color: const Color(0xFF4F46E5), onTap: () => context.push('/session/quiz')),
                _ModeCard(icon: '✍️', title: 'Yozib javob', desc: 'O\'zbekcha yozib kiritasiz', color: const Color(0xFF059669), onTap: () => context.push('/session/typing')),
                _ModeCard(icon: '🔀', title: 'Shuffle (Aralash)', desc: 'Har so\'z uchun tasodifiy rejim', color: const Color(0xFFF59E0B), onTap: () => context.push('/session/flashcard?mode=shuffle')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon, title, desc;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({required this.icon, required this.title, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
            ),
            Icon(Icons.play_circle_fill, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}
