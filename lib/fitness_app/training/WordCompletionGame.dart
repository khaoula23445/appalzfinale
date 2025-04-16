import 'package:flutter/material.dart';

class WordCompletionGame extends StatefulWidget {
  const WordCompletionGame({super.key});

  @override
  State<WordCompletionGame> createState() => _WordCompletionGameState();
}

class _WordCompletionGameState extends State<WordCompletionGame> {
  // Words in French and Arabic (Algerian dialect)
  final List<Map<String, dynamic>> _words = [
    // French words
    {
      'word': 'école',
      'hint': 'é__le',
      'language': 'Français',
      'translation': 'المدرسة',
    },
    {
      'word': 'soleil',
      'hint': 'so__il',
      'language': 'Français',
      'translation': 'الشمس',
    },
    {
      'word': 'maison',
      'hint': 'ma__on',
      'language': 'Français',
      'translation': 'الدار',
    },
    {
      'word': 'pain',
      'hint': 'p__n',
      'language': 'Français',
      'translation': 'الخبز',
    },

    // Algerian Arabic words (Darija)
    {
      'word': 'كتاب',
      'hint': 'ك__اب',
      'language': 'عربية',
      'translation': 'livre',
    },
    {
      'word': 'قلم',
      'hint': 'ق__م',
      'language': 'عربية',
      'translation': 'stylo',
    },
    {
      'word': 'سيارة',
      'hint': 'س__رة',
      'language': 'عربية',
      'translation': 'voiture',
    },
    {'word': 'ماء', 'hint': 'م__ء', 'language': 'عربية', 'translation': 'eau'},
  ];

  int _currentIndex = 0;
  String _userInput = '';
  bool _isCorrect = false;
  bool _showResult = false;

  void _checkAnswer() {
    setState(() {
      _showResult = true;
      _isCorrect =
          _userInput.toLowerCase() ==
          _words[_currentIndex]['word'].toLowerCase();
    });
  }

  void _nextWord() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _userInput = '';
      _showResult = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _words[_currentIndex];
    final isArabic = currentWord['language'] == 'عربية';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إكمال الكلمة - Compléter le mot',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'اللغة: ${currentWord['language']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            Text(
              'Langue: ${currentWord['language']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              isArabic ? 'أكمل الكلمة:' : 'Complétez le mot:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              currentWord['hint'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: isArabic ? 'Tahoma' : null,
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 10),
            Text(
              isArabic
                  ? 'ترجمة: ${currentWord['translation']}'
                  : 'Traduction: ${currentWord['translation']}',
              style: const TextStyle(fontSize: 16),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => _userInput = value,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: isArabic ? 'إجابتك' : 'Votre réponse',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text(isArabic ? 'تحقق' : 'Vérifier'),
            ),
            if (_showResult)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _isCorrect
                        ? (isArabic ? 'صحيح! 🎉' : 'Correct! 🎉')
                        : (isArabic ? 'غير صحيح 😢' : 'Incorrect 😢'),
                    style: TextStyle(
                      fontSize: 20,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  if (!_isCorrect)
                    Text(
                      isArabic
                          ? 'الكلمة الصحيحة: ${currentWord['word']}'
                          : 'Le mot correct: ${currentWord['word']}',
                      style: const TextStyle(fontSize: 18),
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _nextWord,
                    child: Text(isArabic ? 'الكلمة التالية' : 'Mot suivant'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
