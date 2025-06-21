import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';

class TakeQuizPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const TakeQuizPage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _TakeQuizPageState createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _questions = [];
  Map<int, int?> _selectedAnswers = {};
  bool _quizSubmitted = false;
  int _score = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    scrollController =
        ScrollController()..addListener(() {
          if (scrollController.offset >= 24) {
            if (topBarOpacity != 1.0) {
              setState(() {
                topBarOpacity = 1.0;
              });
            }
          } else if (scrollController.offset <= 24 &&
              scrollController.offset >= 0) {
            if (topBarOpacity != scrollController.offset / 24) {
              setState(() {
                topBarOpacity = scrollController.offset / 24;
              });
            }
          } else if (scrollController.offset <= 0) {
            if (topBarOpacity != 0.0) {
              setState(() {
                topBarOpacity = 0.0;
              });
            }
          }
        });

    _animationController.forward();
    _loadQuestions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(widget.patientId)
              .collection('quiz_questions')
              .where('active', isEqualTo: true)
              .get();

      setState(() {
        _questions =
            querySnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
        _selectedAnswers = {
          for (var i = 0; i < _questions.length; i++) i: null,
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading questions: $e')));
    }
  }

  void _submitQuiz() {
    if (_selectedAnswers.values.any((answer) => answer == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctAnswerIndex']) {
        correctAnswers++;
      }
    }

    setState(() {
      _score = ((correctAnswers / _questions.length) * 100).round();
      _quizSubmitted = true;
    });

    // Scroll to the top to show results
    scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    _saveQuizResult(correctAnswers, _questions.length);
  }

  Future<void> _saveQuizResult(int correctAnswers, int totalQuestions) async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('quiz_results')
          .add({
            'date': FieldValue.serverTimestamp(),
            'score': _score,
            'correctAnswers': correctAnswers,
            'totalQuestions': totalQuestions,
          });
    } catch (e) {
      print('Error saving quiz result: $e');
    }
  }

  void _restartQuiz() {
    setState(() {
      _selectedAnswers = {for (var i = 0; i < _questions.length; i++) i: null};
      _quizSubmitted = false;
      _score = 0;
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Hard':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  30 * (1.0 - topBarAnimation!.value),
                  0.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(
                          0.4 * topBarOpacity,
                        ),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16 - 8.0 * topBarOpacity,
                          bottom: 12 - 8.0 * topBarOpacity,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${widget.patientName}\'s Quiz',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 100),
                _questions.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        if (_quizSubmitted)
                          Container(
                            margin: EdgeInsets.all(16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  _score >= 70
                                      ? Colors.green.withOpacity(0.2)
                                      : _score >= 40
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: FitnessAppTheme.grey.withOpacity(0.2),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 8.0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Quiz Results',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Your score: $_score%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _score >= 70
                                            ? Colors.green
                                            : _score >= 40
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${(_score / 100 * _questions.length).round()} out of ${_questions.length} correct',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _restartQuiz,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        FitnessAppTheme.nearlyDarkBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Take Quiz Again',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ..._questions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final question = entry.value;
                          final answers = List<String>.from(
                            question['answers'],
                          );
                          final correctIndex = question['correctAnswerIndex'];
                          final difficulty = question['difficulty'] ?? 'Easy';

                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: FitnessAppTheme.grey.withOpacity(0.2),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 8.0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(
                                            difficulty,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          difficulty,
                                          style: TextStyle(
                                            color: _getDifficultyColor(
                                              difficulty,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'Question ${index + 1}/${_questions.length}',
                                        style: TextStyle(
                                          color: FitnessAppTheme.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    question['question'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ...answers.asMap().entries.map((answerEntry) {
                                    final answerIndex = answerEntry.key;
                                    final answerText = answerEntry.value;
                                    final isSelected =
                                        _selectedAnswers[index] == answerIndex;
                                    final isCorrect =
                                        answerIndex == correctIndex;
                                    final showCorrectAnswer =
                                        _quizSubmitted && isCorrect;
                                    final showWrongAnswer =
                                        _quizSubmitted &&
                                        isSelected &&
                                        !isCorrect;

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: InkWell(
                                        onTap:
                                            _quizSubmitted
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _selectedAnswers[index] =
                                                        answerIndex;
                                                  });
                                                },
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                showCorrectAnswer
                                                    ? Colors.green.withOpacity(
                                                      0.1,
                                                    )
                                                    : showWrongAnswer
                                                    ? Colors.red.withOpacity(
                                                      0.1,
                                                    )
                                                    : isSelected
                                                    ? FitnessAppTheme
                                                        .nearlyDarkBlue
                                                        .withOpacity(0.1)
                                                    : FitnessAppTheme
                                                        .background,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  showCorrectAnswer
                                                      ? Colors.green
                                                      : showWrongAnswer
                                                      ? Colors.red
                                                      : isSelected
                                                      ? FitnessAppTheme
                                                          .nearlyDarkBlue
                                                      : FitnessAppTheme.grey
                                                          .withOpacity(0.4),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                showCorrectAnswer
                                                    ? Icons.check_circle
                                                    : showWrongAnswer
                                                    ? Icons.cancel
                                                    : isSelected
                                                    ? Icons.radio_button_checked
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color:
                                                    showCorrectAnswer
                                                        ? Colors.green
                                                        : showWrongAnswer
                                                        ? Colors.red
                                                        : isSelected
                                                        ? FitnessAppTheme
                                                            .nearlyDarkBlue
                                                        : FitnessAppTheme.grey,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  answerText,
                                                  style: TextStyle(
                                                    color:
                                                        showCorrectAnswer
                                                            ? Colors.green
                                                            : showWrongAnswer
                                                            ? Colors.red
                                                            : FitnessAppTheme
                                                                .darkerText,
                                                    fontWeight:
                                                        showCorrectAnswer ||
                                                                showWrongAnswer
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  if (_quizSubmitted)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        _selectedAnswers[index] == correctIndex
                                            ? 'Correct!'
                                            : 'Correct answer: ${answers[correctIndex]}',
                                        style: TextStyle(
                                          color:
                                              _selectedAnswers[index] ==
                                                      correctIndex
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (!_quizSubmitted)
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: _submitQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Submit Quiz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 80),
                      ],
                    ),
              ],
            ),
          ),
          getAppBarUI(),
        ],
      ),
    );
  }
}
