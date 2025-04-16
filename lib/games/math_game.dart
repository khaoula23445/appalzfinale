import 'dart:math';
import 'package:flutter/material.dart';

class MathGame extends StatefulWidget {
  const MathGame({super.key});

  @override
  State<MathGame> createState() => _MathGameState();
}

class _MathGameState extends State<MathGame> {
  // Game variables
  int _num1 = 0;
  int _num2 = 0;
  int _correctAnswer = 0;
  int? _userAnswer;
  bool _isCorrect = false;
  bool _showResult = false;
  int _score = 0;
  int _level = 1;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    setState(() {
      // Adjust numbers based on level
      _num1 = random.nextInt(5 * _level) + 1;
      _num2 = random.nextInt(5 * _level) + 1;
      _correctAnswer = _num1 + _num2;
      _userAnswer = null;
      _answerController.clear();
      _showResult = false;
    });
  }

  void _checkAnswer() {
    if (_userAnswer == null) return;

    setState(() {
      _showResult = true;
      _isCorrect = _userAnswer == _correctAnswer;

      if (_isCorrect) {
        _score += 10;
        // Level up every 3 correct answers
        if (_score % 30 == 0) {
          _level++;
        }
      } else {
        // Penalty for wrong answer
        _score = max(0, _score - 5);
      }
    });
  }

  // Bilingual text helper
  String _getText(String arabic, String french) {
    return '$arabic - $french';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getText('حساب بسيط', 'Calcul Simple'),
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score and Level display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _getText('النقاط', 'Score'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _getText('المستوى', 'Niveau'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$_level',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Question
            Text(
              _getText('كم يساوي؟', 'Combien ça fait?'),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              '$_num1 + $_num2 = ?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // Answer input
            SizedBox(
              width: 200,
              child: TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: _getText('الإجابة', 'Réponse'),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _answerController.clear();
                      setState(() {
                        _userAnswer = null;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _userAnswer = int.tryParse(value);
                  });
                },
                onSubmitted: (_) => _checkAnswer(),
              ),
            ),
            const SizedBox(height: 20),

            // Check button
            ElevatedButton(
              onPressed: _userAnswer != null ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: Text(
                _getText('تحقق', 'Vérifier'),
                style: const TextStyle(fontSize: 18),
              ),
            ),

            // Result feedback
            if (_showResult)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _isCorrect
                        ? _getText('صحيح! 🎉', 'Correct! 🎉')
                        : _getText('خطأ! 😢', 'Faux! 😢'),
                    style: TextStyle(
                      fontSize: 22,
                      color: _isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isCorrect)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _getText(
                          'الجواب الصحيح: $_correctAnswer',
                          'Bonne réponse: $_correctAnswer',
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      _getText('السؤال التالي', 'Question suivante'),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
