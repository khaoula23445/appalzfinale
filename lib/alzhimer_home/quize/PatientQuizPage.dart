import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';

class PatientQuizPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientQuizPage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _PatientQuizPageState createState() => _PatientQuizPageState();
}

class _PatientQuizPageState extends State<PatientQuizPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  String _currentFilter = 'All';
  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];
  bool _activeStatus = true;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final validAnswers =
            _answerControllers
                .where((controller) => controller.text.trim().isNotEmpty)
                .toList();

        if (validAnswers.length < 2) {
          _showErrorDialog('Please provide at least 2 answers');
          return;
        }

        if (_correctAnswerIndex >= validAnswers.length) {
          _showErrorDialog('Correct answer index is out of range');
          return;
        }

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('quiz_questions')
            .add({
              'question': _questionController.text,
              'answers': validAnswers.map((c) => c.text).toList(),
              'correctAnswerIndex': _correctAnswerIndex,
              'difficulty': _difficultyOptions[_correctAnswerIndex],
              'active': _activeStatus,
              'createdAt': FieldValue.serverTimestamp(),
            });

        _questionController.clear();
        for (var controller in _answerControllers) {
          controller.clear();
        }
        setState(() {
          _correctAnswerIndex = 0;
          _activeStatus = true;
        });

        _showSuccessDialog('Question added successfully');
      } catch (e) {
        _showErrorDialog('Error adding question: $e');
      }
    }
  }

  Future<void> _updateQuestion(String questionId) async {
    if (_formKey.currentState!.validate()) {
      try {
        final validAnswers =
            _answerControllers
                .where((controller) => controller.text.trim().isNotEmpty)
                .toList();

        if (validAnswers.length < 2) {
          _showErrorDialog('Please provide at least 2 answers');
          return;
        }

        if (_correctAnswerIndex >= validAnswers.length) {
          _showErrorDialog('Correct answer index is out of range');
          return;
        }

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('quiz_questions')
            .doc(questionId)
            .update({
              'question': _questionController.text,
              'answers': validAnswers.map((c) => c.text).toList(),
              'correctAnswerIndex': _correctAnswerIndex,
              'difficulty': _difficultyOptions[_correctAnswerIndex],
              'active': _activeStatus,
            });

        _showSuccessDialog('Question updated successfully');
      } catch (e) {
        _showErrorDialog('Error updating question: $e');
      }
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('quiz_questions')
          .doc(questionId)
          .delete();

      _showSuccessDialog('Question deleted successfully');
    } catch (e) {
      _showErrorDialog('Error deleting question: $e');
    }
  }

  Future<void> _toggleQuestionStatus(
    String questionId,
    bool currentStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('quiz_questions')
          .doc(questionId)
          .update({'active': !currentStatus});

      _showSuccessDialog('Question status updated');
    } catch (e) {
      _showErrorDialog('Error updating question status: $e');
    }
  }

  Future<void> _setAllQuestionsActive(bool active) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(widget.patientId)
              .collection('quiz_questions')
              .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'active': active});
      }

      await batch.commit();
      _showSuccessDialog(
        active ? 'All questions activated' : 'All questions deactivated',
      );
    } catch (e) {
      _showErrorDialog('Error updating questions: $e');
    }
  }

  void _showDeleteConfirmation(String questionId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this question?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteQuestion(questionId);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Success'),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_formKey.currentState != null) {
                    _questionController.clear();
                    for (var controller in _answerControllers) {
                      controller.clear();
                    }
                    setState(() {
                      _correctAnswerIndex = 0;
                      _activeStatus = true;
                    });
                  }
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
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
                                  '${widget.patientName} Quiz Questions',
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
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert),
                              itemBuilder:
                                  (BuildContext context) => [
                                    PopupMenuItem(
                                      value: 'activate_all',
                                      child: Text('Activate All Questions'),
                                    ),
                                    PopupMenuItem(
                                      value: 'deactivate_all',
                                      child: Text('Deactivate All Questions'),
                                    ),
                                  ],
                              onSelected: (String value) {
                                if (value == 'activate_all') {
                                  _setAllQuestionsActive(true);
                                } else if (value == 'deactivate_all') {
                                  _setAllQuestionsActive(false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      _buildFilterChips(),
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children:
            ['All', 'Easy', 'Medium', 'Hard'].map((String filter) {
              return FilterChip(
                label: Text(filter),
                selected: _currentFilter == filter,
                onSelected: (bool selected) {
                  setState(() {
                    _currentFilter = selected ? filter : 'All';
                  });
                },
                selectedColor:
                    filter == 'Active'
                        ? Colors.green.withOpacity(0.2)
                        : filter == 'Inactive'
                        ? Colors.grey.withOpacity(0.2)
                        : _getDifficultyColor(filter).withOpacity(0.2),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color:
                      _currentFilter == filter
                          ? filter == 'Active'
                              ? Colors.green
                              : filter == 'Inactive'
                              ? Colors.grey
                              : _getDifficultyColor(filter)
                          : Colors.black,
                ),
                checkmarkColor:
                    filter == 'Active'
                        ? Colors.green
                        : filter == 'Inactive'
                        ? Colors.grey
                        : _getDifficultyColor(filter),
              );
            }).toList(),
      ),
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
                SizedBox(height: MediaQuery.of(context).padding.top + 140),
                _buildQuestionsList(),
                SizedBox(height: 80),
              ],
            ),
          ),
          getAppBarUI(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuestionDialog(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: FitnessAppTheme.nearlyDarkBlue,
        elevation: 4.0,
      ),
    );
  }

  Widget _buildQuestionsList() {
    Query questionsQuery = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('quiz_questions');

    if (_currentFilter == 'Active') {
      questionsQuery = questionsQuery.where('active', isEqualTo: true);
    } else if (_currentFilter == 'Inactive') {
      questionsQuery = questionsQuery.where('active', isEqualTo: false);
    } else if (_currentFilter == 'Easy' ||
        _currentFilter == 'Medium' ||
        _currentFilter == 'Hard') {
      questionsQuery = questionsQuery.where(
        'difficulty',
        isEqualTo: _currentFilter,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: questionsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No questions found. Tap + to add a new question.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        var docs = snapshot.data!.docs;
        docs.sort((a, b) {
          var aTime = a['createdAt'] as Timestamp?;
          var bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final question = doc.data() as Map<String, dynamic>;
            final answers = List<String>.from(question['answers'] ?? []);
            final correctIndex = question['correctAnswerIndex'] ?? 0;
            final isActive = question['active'] ?? true;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                title: Text(
                  question['question'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
                leading: Icon(
                  isActive ? Icons.check_circle : Icons.remove_circle,
                  color: isActive ? Colors.green : Colors.grey,
                ),
                subtitle: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          question['difficulty'] ?? 'Easy',
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question['difficulty'] ?? 'Easy',
                        style: TextStyle(
                          color: _getDifficultyColor(
                            question['difficulty'] ?? 'Easy',
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Answers:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        ...answers.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final answer = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        idx == correctIndex
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            idx == correctIndex
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    answer,
                                    style: TextStyle(
                                      color:
                                          idx == correctIndex
                                              ? Colors.green
                                              : Colors.black,
                                      fontWeight:
                                          idx == correctIndex
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showQuestionDialog(context, doc.id, question);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isActive ? Icons.toggle_on : Icons.toggle_off,
                                color: isActive ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                _toggleQuestionStatus(doc.id, isActive);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(doc.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQuestionDialog(
    BuildContext context, [
    String? questionId,
    Map<String, dynamic>? questionData,
  ]) {
    final isEditing = questionId != null;

    if (isEditing) {
      _questionController.text = questionData?['question'] ?? '';
      final answers = List<String>.from(questionData?['answers'] ?? []);
      for (int i = 0; i < _answerControllers.length; i++) {
        _answerControllers[i].text = i < answers.length ? answers[i] : '';
      }
      _correctAnswerIndex = questionData?['correctAnswerIndex'] ?? 0;
      _activeStatus = questionData?['active'] ?? true;
    } else {
      _questionController.clear();
      for (var controller in _answerControllers) {
        controller.clear();
      }
      _correctAnswerIndex = 0;
      _activeStatus = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit Question' : 'Add New Question',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FitnessAppTheme.nearlyDarkBlue,
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            labelText: 'Question',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: Icon(Icons.question_answer),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        ..._answerControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: _correctAnswerIndex,
                                  onChanged: (int? value) {
                                    setState(() {
                                      _correctAnswerIndex = value!;
                                    });
                                  },
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'Answer ${index + 1}',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _difficultyOptions[_correctAnswerIndex],
                          items:
                              _difficultyOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(value),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _correctAnswerIndex = _difficultyOptions
                                    .indexOf(value);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Difficulty',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SwitchListTile(
                          title: Text('Active'),
                          value: _activeStatus,
                          onChanged: (value) {
                            setState(() {
                              _activeStatus = value;
                            });
                          },
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _questionController.clear();
                                for (var controller in _answerControllers) {
                                  controller.clear();
                                }
                                setState(() {
                                  _correctAnswerIndex = 0;
                                  _activeStatus = true;
                                });
                              },
                              child: Text(
                                'CANCEL',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (isEditing) {
                                  await _updateQuestion(questionId!);
                                } else {
                                  await _addQuestion();
                                }
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'UPDATE' : 'SAVE',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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
    );
  }
}
