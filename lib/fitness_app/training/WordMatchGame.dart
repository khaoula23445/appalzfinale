import 'package:flutter/material.dart';

class WordMatchGame extends StatefulWidget {
  const WordMatchGame({super.key});

  @override
  State<WordMatchGame> createState() => _WordMatchGameState();
}

class _WordMatchGameState extends State<WordMatchGame> {
  final List<_WordQuestion> _questions = [
    _WordQuestion(
      incompleteWord: 'Ap_ _ e',
      options: ['Apple', 'Angle', 'Amply'],
      answer: 'Apple',
    ),
    _WordQuestion(
      incompleteWord: 'Tr _ _',
      options: ['Tree', 'Trap', 'Trip'],
      answer: 'Tree',
    ),
    _WordQuestion(
      incompleteWord: 'Ca _',
      options: ['Cat', 'Cap', 'Car'],
      answer: 'Cat',
    ),
    _WordQuestion(
      incompleteWord: 'Ho _ _',
      options: ['Hope', 'Hole', 'Home'],
      answer: 'Home',
    ),
  ];

  int _currentIndex = 0;
  bool _isCorrect = false;
  bool _answered = false;

  void _checkAnswer(String selected) {
    setState(() {
      _answered = true;
      _isCorrect = selected == _questions[_currentIndex].answer;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _questions.length;
        _answered = false;
        _isCorrect = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Word Match Game'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Complete the word:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              question.incompleteWord,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ...question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor:
                        _answered
                            ? (option == question.answer
                                ? Colors.green
                                : option == _questions[_currentIndex].answer
                                ? Colors.red
                                : Colors.grey)
                            : null,
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_answered)
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? Colors.green : Colors.red,
                size: 48,
              ),
          ],
        ),
      ),
    );
  }
}

class _WordQuestion {
  final String incompleteWord;
  final List<String> options;
  final String answer;

  _WordQuestion({
    required this.incompleteWord,
    required this.options,
    required this.answer,
  });
}
