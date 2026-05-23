import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../store/app_store.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});
  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _searchCtrl = TextEditingController();
  List<Word> _results = [];
  

  @override
  void initState() {
    super.initState();
    _results = context.read<AppStore>().words;
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      setState(() => _results = context.read<AppStore>().words);
      return;
    }
    
    final res = await context.read<AppStore>().searchWords(q);
    setState(() { _results = res; });
  }

  Color _masteryColor(int level) {
    if (level >= 4) return const Color(0xFF059669);
    if (level >= 2) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Lug\'at', style: TextStyle(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'So\'z qidirish...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0F0F1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppStore>(
        builder: (context, store, _) {
          final list = _searchCtrl.text.isEmpty ? store.words : _results;
          if (store.loading) return const Center(child: CircularProgressIndicator());
          if (list.isEmpty) {
            return const Center(child: Text('Hali so\'z qo\'shilmagan 📚', style: TextStyle(color: Colors.white54)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final w = list[i];
              return Dismissible(
                key: Key('word_${w.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => store.deleteWord(w.id!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.english, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            if (w.pronunciation != null)
                              Text(w.pronunciation!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(w.uzbek, style: const TextStyle(color: Colors.white70)),
                            if (w.example != null)
                              Text(w.example!, style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: _masteryColor(w.masteryLevel).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text('${w.masteryLevel}', style: TextStyle(color: _masteryColor(w.masteryLevel), fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(height: 4),
                          Text('daraja', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
