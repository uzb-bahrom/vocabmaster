import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../store/app_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStore>(
      builder: (context, store, _) {
        final progress = store.todayProgress;
        final stats = store.stats;
        final addedToday = stats['addedToday'] ?? 0;
        final total = stats['total'] ?? 0;
        final mastered = stats['mastered'] ?? 0;
        final streak = progress?.streakDay ?? 0;
        final masteredPct = total == 0 ? 0.0 : mastered / total;

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Salom! 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('VocabMaster', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF7C3AED)),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text('$streak kun', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Kunlik maqsad
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kunlik maqsad', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text('$addedToday / 20', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (addedToday / 20).clamp(0.0, 1.0),
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          addedToday >= 20 ? '🎉 Maqsadga yetdingiz!' : '${20 - addedToday} ta qoldi',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats cards
                  Row(
                    children: [
                      _StatCard(label: 'Jami so\'zlar', value: '$total', icon: '📚', color: const Color(0xFF1E1E3A)),
                      const SizedBox(width: 12),
                      _StatCard(label: 'O\'zlashtirilgan', value: '${(masteredPct * 100).toInt()}%', icon: '✅', color: const Color(0xFF1E1E3A)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick actions
                  const Text('Tezkor amallar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  _ActionCard(
                    icon: '➕',
                    title: 'So\'z qo\'shish',
                    subtitle: 'Yangi so\'z qo\'shing (kuniga 20 ta)',
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/add-word'),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: '🎮',
                    title: 'Takrorlash',
                    subtitle: '${stats['dueToday'] ?? 0} ta so\'z kutmoqda',
                    color: const Color(0xFF059669),
                    onTap: () => context.go('/game'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
