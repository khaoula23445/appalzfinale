// TODO Implement this library.
import 'package:flutter/material.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];
  Color? targetColor;
  Color? selectedColor;
  int score = 0;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    setState(() {
      colors.shuffle();
      targetColor = colors[0];
      selectedColor = null;
    });
  }

  void _selectColor(Color color) {
    if (selectedColor != null) return;

    setState(() {
      selectedColor = color;
      attempts++;
      if (color == targetColor) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _newRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Match Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                score = 0;
                attempts = 0;
              });
              _newRound();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Score: $score / $attempts',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text('Find this color:', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: targetColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Select the matching color:',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  return GestureDetector(
                    onTap: () => _selectColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              selectedColor == color
                                  ? (color == targetColor
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.black,
                          width: selectedColor == color ? 4 : 2,
                        ),
                      ),
                      child:
                          selectedColor == color
                              ? Center(
                                child: Icon(
                                  color == targetColor
                                      ? Icons.check
                                      : Icons.close,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                              : null,
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
