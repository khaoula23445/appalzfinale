import 'package:alzheimer_app/fitness_app/training/VisualPuzzleGame.dart';
import 'package:alzheimer_app/fitness_app/training/WordCompletionGame.dart';
import 'package:alzheimer_app/fitness_app/training/math_game.dart';
import 'package:flutter/material.dart';
import 'memory_card_game.dart';
import 'color_match_game.dart';
import 'object_recall_game.dart';
import 'sequence_game.dart';
// ... (keep existing imports)

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألعاب الذاكرة - Jeux de mémoire',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: OrientationBuilder(
          builder: (context, orientation) {
            return GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildGameCard(
                  context,
                  'بطاقات الذاكرة\nCartes mémoire',
                  Icons.photo_library,
                  Colors.blue,
                  const MemoryCardGame(),
                ),
                _buildGameCard(
                  context,
                  'تطابق الألوان\nCorrespondance des couleurs',
                  Icons.color_lens,
                  Colors.green,
                  const ColorMatchGame(),
                ),
                _buildGameCard(
                  context,
                  'تذكر الأشياء\nRappel d\'objets',
                  Icons.category,
                  Colors.orange,
                  const ObjectRecallGame(),
                ),
                _buildGameCard(
                  context,
                  'تسلسل الأرقام\nSéquence numérique',
                  Icons.format_list_numbered,
                  Colors.purple,
                  const SequenceGame(),
                ),
                _buildGameCard(
                  context,
                  'حساب بسيط\nCalcul simple',
                  Icons.calculate,
                  Colors.indigo,
                  const MathGame(),
                ),
                _buildGameCard(
                  context,
                  'لغز الصور\nPuzzle Visuel',
                  Icons
                      .extension, // Changed from Icons.puzzle_piece to Icons.extension
                  Colors.amber,
                  const PuzzleWithIcons(),
                ),
                _buildGameCard(
                  context,
                  'إكمال الكلمات\nCompléter les mots',
                  Icons.text_fields,
                  Colors.red,
                  const WordCompletionGame(),
                ),
                _buildGameCard(
                  context,
                  'ذاكرة الصوت\nMémoire sonore',
                  Icons.music_note,
                  Colors.teal,
                  const Placeholder(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget gameScreen,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => gameScreen),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: color.withOpacity(0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
