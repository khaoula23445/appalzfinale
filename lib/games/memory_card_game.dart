// TODO Implement this library.
import 'package:flutter/material.dart';

class MemoryCardGame extends StatefulWidget {
  const MemoryCardGame({super.key});

  @override
  State<MemoryCardGame> createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  List<String> cardImages = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
  ];
  List<bool> cardFlips = [];
  int? firstCardIndex;
  int? secondCardIndex;
  int matchedPairs = 0;
  bool processing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      cardFlips = List<bool>.filled(cardImages.length, false);
      cardImages.shuffle();
      matchedPairs = 0;
      firstCardIndex = null;
      secondCardIndex = null;
      processing = false;
    });
  }

  void _flipCard(int index) {
    if (processing || cardFlips[index] || index == firstCardIndex) return;

    setState(() {
      cardFlips[index] = true;
    });

    if (firstCardIndex == null) {
      firstCardIndex = index;
    } else {
      secondCardIndex = index;
      processing = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (cardImages[firstCardIndex!] == cardImages[secondCardIndex!]) {
      matchedPairs++;
      if (matchedPairs == cardImages.length ~/ 2) {
        _showGameCompleteDialog();
      }
      firstCardIndex = null;
      secondCardIndex = null;
      processing = false;
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          cardFlips[firstCardIndex!] = false;
          cardFlips[secondCardIndex!] = false;
          firstCardIndex = null;
          secondCardIndex = null;
          processing = false;
        });
      });
    }
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text('You matched all the pairs!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initializeGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Card Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: OrientationBuilder(
          builder: (context, orientation) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: orientation == Orientation.portrait ? 3 : 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cardImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: cardFlips[index] ? Colors.white : Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: Center(
                      child:
                          cardFlips[index]
                              ? Text(
                                cardImages[index],
                                style: const TextStyle(fontSize: 36),
                              )
                              : const Icon(
                                Icons.question_mark,
                                size: 36,
                                color: Colors.white,
                              ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
