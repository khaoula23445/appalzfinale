import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

class CognitiveGamesMenu extends StatelessWidget {
  const CognitiveGamesMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cognitive Games'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _GameCard(
              title: 'Memory Sequence',
              icon: Icons.memory,
              color: Colors.blue,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemorySequenceGame(),
                    ),
                  ),
            ),
            _GameCard(
              title: 'Word Recall',
              icon: Icons.text_fields,
              color: Colors.green,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordRecallGame(),
                    ),
                  ),
            ),
            _GameCard(
              title: 'Object Match',
              icon: Icons.image_search,
              color: Colors.orange,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ObjectMatchGame(),
                    ),
                  ),
            ),
            _GameCard(
              title: 'Daily Questions',
              icon: Icons.quiz,
              color: Colors.purple,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyQuestionsGame(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Game 1: Memory Sequence Game
class MemorySequenceGame extends StatefulWidget {
  const MemorySequenceGame({Key? key}) : super(key: key);

  @override
  _MemorySequenceGameState createState() => _MemorySequenceGameState();
}

class _MemorySequenceGameState extends State<MemorySequenceGame> {
  int level = 1;
  List<int> sequence = [];
  List<int> userInput = [];
  bool showingSequence = true;
  int displayIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      sequence = List.generate(2 + level, (_) => Random().nextInt(4));
      userInput = [];
      showingSequence = true;
      displayIndex = 0;
      showSequence();
    });
  }

  void showSequence() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
      setState(() {
        if (displayIndex < sequence.length) {
          displayIndex++;
        } else {
          t.cancel();
          showingSequence = false;
        }
      });
    });
  }

  void handleButtonPress(int index) {
    if (showingSequence) return;

    setState(() {
      userInput.add(index);

      if (userInput.length == sequence.length) {
        bool correct = true;
        for (int i = 0; i < sequence.length; i++) {
          if (userInput[i] != sequence[i]) {
            correct = false;
            break;
          }
        }

        if (correct) {
          level++;
          startGame();
        } else {
          userInput = [];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Sequence')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Level: $level', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(4, (index) {
                bool shouldHighlight =
                    showingSequence &&
                    displayIndex > 0 &&
                    sequence[displayIndex - 1] == index;

                return GestureDetector(
                  onTap: () => handleButtonPress(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color:
                          shouldHighlight
                              ? Colors.primaries[index].withOpacity(0.8)
                              : Colors.primaries[index].withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }),
            ),
            if (showingSequence)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Watch the sequence...'),
              ),
          ],
        ),
      ),
    );
  }
}

// Game 2: Word Recall Game
class WordRecallGame extends StatefulWidget {
  const WordRecallGame({Key? key}) : super(key: key);

  @override
  _WordRecallGameState createState() => _WordRecallGameState();
}

class _WordRecallGameState extends State<WordRecallGame> {
  final List<String> words = ['Apple', 'Sun', 'Tree', 'Book', 'Water'];
  List<String> shownWords = [];
  List<String> userAnswers = [];
  bool showWords = true;
  int score = 0;

  @override
  void initState() {
    super.initState();
    startRound();
  }

  void startRound() {
    setState(() {
      shownWords = List.from(words)..shuffle();
      userAnswers = [];
      showWords = true;
      Future.delayed(const Duration(seconds: 5), () {
        setState(() => showWords = false);
      });
    });
  }

  void checkAnswer(String word) {
    setState(() {
      if (words.contains(word) && !userAnswers.contains(word)) {
        userAnswers.add(word);
        if (userAnswers.length == words.length) {
          score++;
          startRound();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Recall')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Score: $score', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            if (showWords)
              Column(
                children:
                    shownWords
                        .map(
                          (word) =>
                              Text(word, style: const TextStyle(fontSize: 24)),
                        )
                        .toList(),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    words
                        .map(
                          (word) => ElevatedButton(
                            onPressed: () => checkAnswer(word),
                            child: Text(word),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// Game 3: Object Match Game
class ObjectMatchGame extends StatefulWidget {
  const ObjectMatchGame({Key? key}) : super(key: key);

  @override
  _ObjectMatchGameState createState() => _ObjectMatchGameState();
}

class _ObjectMatchGameState extends State<ObjectMatchGame> {
  final List<String> objects = ['🐶', '🐱', '🍎', '🚗', '🏠', '🌳'];
  List<String> gameObjects = [];
  String? selectedObject;
  int? selectedIndex;
  int pairsFound = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      gameObjects =
          List.from(objects)
            ..addAll(objects)
            ..shuffle();
      selectedObject = null;
      selectedIndex = null;
      pairsFound = 0;
    });
  }

  void handleTap(int index) {
    if (gameObjects[index] == '✓' || selectedIndex == index) return;

    setState(() {
      if (selectedObject == null) {
        selectedObject = gameObjects[index];
        selectedIndex = index;
      } else {
        if (selectedObject == gameObjects[index]) {
          gameObjects[selectedIndex!] = '✓';
          gameObjects[index] = '✓';
          pairsFound++;
        }
        selectedObject = null;
        selectedIndex = null;

        if (pairsFound == objects.length) {
          Future.delayed(const Duration(seconds: 1), startGame);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Object Match')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pairs Found: $pairsFound/${objects.length}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(gameObjects.length, (index) {
                return GestureDetector(
                  onTap: () => handleTap(index),
                  child: Card(
                    child: Center(
                      child: Text(
                        gameObjects[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Game 4: Daily Questions Game
class DailyQuestionsGame extends StatefulWidget {
  const DailyQuestionsGame({Key? key}) : super(key: key);

  @override
  _DailyQuestionsGameState createState() => _DailyQuestionsGameState();
}

class _DailyQuestionsGameState extends State<DailyQuestionsGame> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What day is today?',
      'answers': ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
      'correct': DateTime.now().weekday - 1, // 0-based index
    },
    {
      'question': 'What season is it?',
      'answers': ['Spring', 'Summer', 'Fall', 'Winter'],
      'correct': (DateTime.now().month % 12 / 3).floor(), // 0-3
    },
    {
      'question': 'What color is a banana?',
      'answers': ['Red', 'Yellow', 'Blue', 'Green'],
      'correct': 1,
    },
  ];

  int currentQuestion = 0;
  int? selectedAnswer;
  int score = 0;

  void checkAnswer() {
    if (selectedAnswer == questions[currentQuestion]['correct']) {
      setState(() => score++);
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Quiz Complete!'),
              content: Text('Your score: $score/${questions.length}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentQuestion = 0;
                      score = 0;
                      selectedAnswer = null;
                    });
                  },
                  child: const Text('Restart'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Questions')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                questions[currentQuestion]['question'],
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  questions[currentQuestion]['answers'].length,
                  (index) => RadioListTile<int>(
                    title: Text(
                      questions[currentQuestion]['answers'][index],
                      style: const TextStyle(fontSize: 20),
                    ),
                    value: index,
                    groupValue: selectedAnswer,
                    onChanged: (value) {
                      setState(() => selectedAnswer = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedAnswer != null ? checkAnswer : null,
                child: const Text('Submit Answer'),
              ),
              const SizedBox(height: 20),
              Text('Score: $score', style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
