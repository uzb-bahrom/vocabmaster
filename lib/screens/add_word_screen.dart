import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../services/translate_service.dart';
import '../store/app_store.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});
  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _englishCtrl = TextEditingController();
  final _uzbekCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  bool _translating = false;
  bool _saving = false;

  Future<void> _translate() async {
    if (_englishCtrl.text.trim().isEmpty) return;
    setState(() => _translating = true);
    final t = await TranslateService.translateToUzbek(_englishCtrl.text.trim());
    setState(() {
      _translating = false;
      if (t != null) _uzbekCtrl.text = t;
    });
  }

  Future<void> _save() async {
    if (_englishCtrl.text.trim().isEmpty || _uzbekCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inglizcha va o\'zbekcha maydonlarni to\'ldiring!')),
      );
      return;
    }
    setState(() => _saving = true);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final word = Word(
      english: _englishCtrl.text.trim(),
      uzbek: _uzbekCtrl.text.trim(),
      example: _exampleCtrl.text.trim().isEmpty ? null : _exampleCtrl.text.trim(),
      addedDate: today,
      nextReviewDate: today,
    );
    await context.read<AppStore>().addWord(word);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${word.english}" qo\'shildi!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      _englishCtrl.clear();
      _uzbekCtrl.clear();
      _exampleCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('So\'z qo\'shish', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              'Inglizcha *',
              _englishCtrl,
              hint: 'ambiguous',
              suffix: IconButton(
                icon: _translating
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7C3AED),
                  ),
                )
                    : const Icon(Icons.translate, color: Color(0xFF7C3AED)),
                onPressed: _translate,
              ),
            ),
            const SizedBox(height: 14),
            _buildField('O\'zbekcha *', _uzbekCtrl, hint: 'noaniq'),
            const SizedBox(height: 14),
            _buildField(
              'Misol jumla',
              _exampleCtrl,
              hint: 'The instructions were ambiguous.',
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Saqlash',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController ctrl, {
        String? hint,
        Widget? suffix,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _englishCtrl.dispose();
    _uzbekCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }
}