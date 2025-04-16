// TODO Implement this library.
import 'package:flutter/material.dart';

class SequenceGame extends StatefulWidget {
  const SequenceGame({super.key});

  @override
  State<SequenceGame> createState() => _SequenceGameState();
}

class _SequenceGameState extends State<SequenceGame> {
  final List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  List<int> sequence = [];
  List<int> userSequence = [];
  bool showingSequence = false;
  int currentLevel = 1;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _generateSequence();
  }

  void _generateSequence() {
    setState(() {
      sequence = numbers.sublist(0, currentLevel + 1)..shuffle();
      userSequence = [];
      showingSequence = true;
      gameOver = false;
    });

    // Show sequence to user
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showingSequence = false;
      });
    });
  }

  void _selectNumber(int number) {
    if (showingSequence || gameOver) return;

    setState(() {
      userSequence.add(number);
    });

    // Check if selection matches sequence
    bool correct = true;
    for (int i = 0; i < userSequence.length; i++) {
      if (userSequence[i] != sequence[i]) {
        correct = false;
        break;
      }
    }

    if (!correct) {
      setState(() {
        gameOver = true;
      });
      _showResult(false);
    } else if (userSequence.length == sequence.length) {
      setState(() {
        gameOver = true;
      });
      _showResult(true);
    }
  }

  void _showResult(bool success) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(success ? 'Correct!' : 'Try Again'),
            content: Text(
              success
                  ? 'You completed the sequence!'
                  : 'The sequence was incorrect.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    if (success) {
                      currentLevel++;
                    }
                    _generateSequence();
                  });
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Sequence Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                currentLevel = 1;
              });
              _generateSequence();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Level $currentLevel', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            if (showingSequence)
              const Text(
                'Memorize the sequence:',
                style: TextStyle(fontSize: 20),
              )
            else
              const Text(
                'Repeat the sequence:',
                style: TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  final number = numbers[index];
                  final isInSequence = sequence.contains(number);
                  final isInUserSequence = userSequence.contains(number);
                  final isNextInSequence =
                      userSequence.length < sequence.length &&
                      number == sequence[userSequence.length];

                  return GestureDetector(
                    onTap: () => _selectNumber(number),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            showingSequence
                                ? (isInSequence ? Colors.blue : Colors.grey)
                                : (isInUserSequence
                                    ? (isInSequence ? Colors.green : Colors.red)
                                    : (isNextInSequence
                                        ? Colors.blue[200]
                                        : Colors.blue)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          number.toString(),
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
