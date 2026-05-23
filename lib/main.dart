import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/dictionary_screen.dart';
import 'screens/game_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/add_word_screen.dart';
import 'screens/session/flashcard_screen.dart';
import 'screens/session/quiz_screen.dart';
import 'screens/session/typing_screen.dart';
import 'services/notification_service.dart';
import 'store/app_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const VocabMasterApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (ctx, state, shell) => _MainScaffold(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/', builder: (c, s) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/dictionary', builder: (c, s) => const DictionaryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/game', builder: (c, s) => const GameScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/stats', builder: (c, s) => const StatsScreen())]),
      ],
    ),
    GoRoute(path: '/add-word', builder: (c, s) => const AddWordScreen()),
    GoRoute(path: '/session/flashcard', builder: (c, s) => const FlashcardScreen()),
    GoRoute(path: '/session/quiz', builder: (c, s) => const QuizScreen()),
    GoRoute(path: '/session/typing', builder: (c, s) => const TypingScreen()),
  ],
);

class VocabMasterApp extends StatelessWidget {
  const VocabMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStore()..loadAll(),
      child: MaterialApp.router(
        title: 'VocabMaster',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED), brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          useMaterial3: true,
        ),
        routerConfig: _router,
        builder: (context, child) => _SplashWrapper(child: child!),
      ),
    );
  }
}

class _SplashWrapper extends StatefulWidget {
  final Widget child;
  const _SplashWrapper({required this.child});

  @override
  State<_SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<_SplashWrapper> with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(seconds: 2), () {
      _controller.forward().then((_) {
        if (mounted) setState(() => _showSplash = false);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return widget.child;
    return Stack(
      children: [
        widget.child,
        FadeTransition(
          opacity: _fadeAnim,
          child: const _SplashScreen(),
        ),
      ],
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kitob icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF163057),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Kitob chap sahifa
                  Positioned(
                    left: 18,
                    top: 28,
                    child: Container(
                      width: 36,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                          child: Container(height: 3, color: const Color(0xFF64748B)),
                        )),
                      ),
                    ),
                  ),
                  // Kitob o'ng sahifa
                  Positioned(
                    right: 18,
                    top: 28,
                    child: Container(
                      width: 36,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                          child: Container(height: 3, color: const Color(0xFF94A3B8)),
                        )),
                      ),
                    ),
                  ),
                  // A doirasi
                  Positioned(
                    right: 16,
                    top: 20,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A9FD4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MASTER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            const Text(
              'VOCAB',
              style: TextStyle(
                color: Color(0xFF4A9FD4),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _MainScaffold({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        backgroundColor: const Color(0xFF1A1A2E),
        indicatorColor: const Color(0xFF7C3AED).withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Bosh sahifa'),
          NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Lug\'at'),
          NavigationDestination(icon: Icon(Icons.games_outlined), selectedIcon: Icon(Icons.games), label: 'O\'yin'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistika'),
        ],
      ),
    );
  }
}