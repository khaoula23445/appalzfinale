// TODO Implement this library.
import 'package:flutter/material.dart';

class ObjectRecallGame extends StatefulWidget {
  const ObjectRecallGame({super.key});

  @override
  State<ObjectRecallGame> createState() => _ObjectRecallGameState();
}

class _ObjectRecallGameState extends State<ObjectRecallGame> {
  final List<String> objects = [
    '🍎',
    '🚗',
    '🏠',
    '📱',
    '🐦',
    '👓',
    '⌚',
    '📚',
    '🌂',
    '🥾',
    '🎩',
    '🧦',
  ];
  List<String> displayedObjects = [];
  List<String> userSelected = [];
  int currentRound = 1;
  bool showObjects = true;
  bool gameComplete = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    setState(() {
      objects.shuffle();
      displayedObjects = objects.sublist(0, currentRound + 2);
      userSelected = [];
      showObjects = true;
      gameComplete = false;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showObjects = false;
      });
    });
  }

  void _selectObject(String object) {
    if (showObjects || gameComplete) return;

    setState(() {
      if (!userSelected.contains(object)) {
        userSelected.add(object);
      }

      if (userSelected.length == displayedObjects.length) {
        _checkAnswers();
      }
    });
  }

  void _checkAnswers() {
    bool allCorrect = true;
    for (var obj in displayedObjects) {
      if (!userSelected.contains(obj)) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      gameComplete = true;
    });

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(allCorrect ? 'Correct!' : 'Try Again'),
            content: Text(
              allCorrect
                  ? 'You remembered all ${displayedObjects.length} objects!'
                  : 'Some objects were missing.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    if (allCorrect) {
                      currentRound++;
                    }
                    _startRound();
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
        title: const Text('Object Recall Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                currentRound = 1;
              });
              _startRound();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Round $currentRound', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            if (showObjects)
              Text(
                'Memorize these objects:',
                style: const TextStyle(fontSize: 20),
              )
            else
              Text(
                'Select the objects you saw:',
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: objects.length,
                itemBuilder: (context, index) {
                  final object = objects[index];
                  final isDisplayed = displayedObjects.contains(object);
                  final isSelected = userSelected.contains(object);

                  return GestureDetector(
                    onTap: () => _selectObject(object),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            showObjects
                                ? (isDisplayed ? Colors.blue : Colors.grey)
                                : (isSelected
                                    ? (isDisplayed ? Colors.green : Colors.red)
                                    : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          object,
                          style: const TextStyle(fontSize: 36),
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
