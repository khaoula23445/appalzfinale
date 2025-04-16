import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(home: PuzzleWithIcons()));

class PuzzleWithIcons extends StatefulWidget {
  const PuzzleWithIcons({super.key});

  @override
  State<PuzzleWithIcons> createState() => _PuzzleWithIconsState();
}

class _PuzzleWithIconsState extends State<PuzzleWithIcons> {
  final int gridSize = 3;
  List<int> positions = [];
  int? selectedIndex;
  int moveCount = 0;
  bool completed = false;

  // Liste d’icônes pour le puzzle
  final List<IconData> iconList = [
    Icons.star,
    Icons.favorite,
    Icons.face,
    Icons.coffee,
    Icons.pets,
    Icons.sunny,
    Icons.mood,
    Icons.music_note,
    Icons.spa,
  ];

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  void _initPuzzle() {
    positions = List.generate(gridSize * gridSize, (index) => index);
    do {
      positions.shuffle();
    } while (_isSolved());
    moveCount = 0;
    completed = false;
    selectedIndex = null;
    setState(() {});
  }

  bool _isSolved() {
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != i) return false;
    }
    return true;
  }

  void _swapTiles(int index) {
    if (completed) return;

    if (selectedIndex == null) {
      setState(() {
        selectedIndex = index;
      });
    } else {
      setState(() {
        final temp = positions[index];
        positions[index] = positions[selectedIndex!];
        positions[selectedIndex!] = temp;
        selectedIndex = null;
        moveCount++;
        completed = _isSolved();
      });
    }
  }

  Widget _buildTile(int index) {
    final current = positions[index];
    final isCorrect = current == index;
    final icon = iconList[current];
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return GestureDetector(
      onTap: () => _swapTiles(index),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              isCorrect && completed
                  ? Colors.green[200]
                  : colors[current % colors.length].withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedIndex == index ? Colors.black : Colors.white,
            width: 2,
          ),
        ),
        child: Center(child: Icon(icon, size: 40, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status =
        completed ? "✅ Bravo ! - أحسنت" : "🧠 Assemble les icônes - رتب الرموز";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Alzheimer - Icônes'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            status,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Essais: $moveCount - المحاولات: $moveCount",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) => _buildTile(index),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _initPuzzle,
            icon: const Icon(Icons.replay, color: Colors.white),
            label: const Text(
              "Nouveau - جديد",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
